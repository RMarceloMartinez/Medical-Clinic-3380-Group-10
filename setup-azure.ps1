# One-time setup of the Medical Clinic app on Azure (free tiers only).
#
# Creates: resource group, SQL server (Microsoft Entra-only, you as admin),
# free "MedicalClinic" database (auto-pauses at the free limit), firewall rules,
# runs the 7 database scripts, a Free F1 Linux web app with a managed identity,
# gives that identity access to the database, then deploys the app.
#
# Run from the repo root AFTER `az login`:
#   powershell -ExecutionPolicy Bypass -File setup-azure.ps1 -Name clinic3380-rm
#
# Safe to run again: anything that already exists is kept.
# WARNING: it re-runs reset.sql + seed.sql, so data added on the live site is lost.

param(
    # Lowercase letters, numbers and dashes. Becomes https://<Name>.azurewebsites.net
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$Location = "centralus",      # region for the SQL server + database
    # Regions to try, in order, for the free (F1) web app. Free quota is per region,
    # so the script tries each one until Azure accepts.
    [string[]]$AppLocations = @("westus2", "westus3", "eastus2", "northcentralus", "westus",
                                "canadacentral", "eastus", "centralus", "northeurope", "westeurope"),
    [string]$ResourceGroup = "clinic-rg"
)

$ErrorActionPreference = "Continue"

function Step($text) { Write-Host ""; Write-Host "==> $text" -ForegroundColor Cyan }
function Fail($text) { Write-Host "STOPPED: $text" -ForegroundColor Red; exit 1 }
function Check($what) { if ($LASTEXITCODE -ne 0) { Fail $what } }

$Server     = "$Name-sql"
$ServerHost = "$Server.database.windows.net"
$Database   = "MedicalClinic"          # must match the USE line in every .sql file
$Plan       = "$Name-plan"
$App        = $Name
$Sqlcmd     = "C:\Program Files\SqlCmd\sqlcmd.exe"   # go-sqlcmd (supports Entra login)

# Runs SQL against the Azure database with your `az login` identity.
# Shows the output only when something fails.
function Invoke-AzureSql([string[]]$SqlArgs, [string]$What) {
    $output = & $Sqlcmd -S "tcp:$ServerHost,1433" -d $Database `
        --authentication-method ActiveDirectoryDefault -l 120 -b @SqlArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        $output | ForEach-Object { Write-Host $_ }
        Fail $What
    }
    return $output
}

# ---------------------------------------------------------------------------
Step "Checking tools and folder"

if ($Name -notmatch '^[a-z0-9-]{3,40}$') {
    Fail "-Name must be 3-40 lowercase letters, numbers or dashes (e.g. clinic3380-rm)."
}
if (-not (Test-Path "backend\ClinicApi.csproj")) {
    Fail "Run this from the repo root (C:\Projects\Medical-Clinic-3380-Group-10)."
}
if (-not (Select-String -Path "backend\Program.cs" -Pattern "UseStaticFiles" -Quiet)) {
    Fail "backend\Program.cs does not serve the website yet. Do the Program.cs step first."
}
az version -o none
Check "Azure CLI not found. Install it: winget install -e --id Microsoft.AzureCLI (then reopen PowerShell)."
if (-not (Test-Path $Sqlcmd)) {
    Fail "go-sqlcmd not found. Install it: winget install -e --id Microsoft.Sqlcmd (then reopen PowerShell)."
}

$meId  = az ad signed-in-user show --query id -o tsv
Check "Could not read your Azure sign-in. Run: az login"
$meUpn = az ad signed-in-user show --query userPrincipalName -o tsv
$subscription = az account show --query name -o tsv
Write-Host "Subscription:   $subscription"
Write-Host "Database admin: $meUpn"

# ---------------------------------------------------------------------------
Step "Resource group '$ResourceGroup' in $Location"
az group create -n $ResourceGroup -l $Location -o none
Check "create the resource group"

# ---------------------------------------------------------------------------
Step "SQL server $ServerHost in $Location (Microsoft Entra-only login, you as admin)"
$found = az sql server list -g $ResourceGroup --query "[?name=='$Server'].name" -o tsv
if ($found) {
    Write-Host "Already exists."
} else {
    az sql server create -g $ResourceGroup -n $Server -l $Location `
        --enable-ad-only-auth `
        --external-admin-principal-type User `
        --external-admin-name $meUpn `
        --external-admin-sid $meId -o none
    Check "create the SQL server (if the name is taken, run again with another -Name)"
}

Step "Firewall: Azure services + this computer"
az sql server firewall-rule create -g $ResourceGroup -s $Server -n AllowAzureServices `
    --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 -o none
Check "allow Azure services"
$myIp = (Invoke-RestMethod -Uri "https://api.ipify.org").Trim()
az sql server firewall-rule create -g $ResourceGroup -s $Server -n ThisComputer `
    --start-ip-address $myIp --end-ip-address $myIp -o none
Check "allow this computer's IP ($myIp)"
Write-Host "Allowed $myIp"

# ---------------------------------------------------------------------------
Step "Free database '$Database' (auto-pauses when the monthly free amount is used up)"
$found = az sql db list -g $ResourceGroup -s $Server --query "[?name=='$Database'].name" -o tsv
if ($found) {
    Write-Host "Already exists."
} else {
    az sql db create -g $ResourceGroup -s $Server -n $Database `
        --edition GeneralPurpose --family Gen5 --capacity 2 --compute-model Serverless `
        --use-free-limit true --free-limit-exhaustion-behavior AutoPause -o none
    Check "create the free database"
}

# ---------------------------------------------------------------------------
Step "Building the schema and sample data (same order as on your laptop)"
foreach ($file in "reset", "schema", "triggers", "views", "seed", "queries", "reports") {
    Write-Host "  database\$file.sql"
    Invoke-AzureSql -SqlArgs @("-i", "database\$file.sql") -What "database\$file.sql failed (output above)" | Out-Null
}
$tables = Invoke-AzureSql -SqlArgs @("-h", "-1", "-Q", "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.tables;") -What "count tables"
Write-Host ("Tables in the Azure database: " + ($tables | Where-Object { "$_".Trim() } | Select-Object -First 1).ToString().Trim())

# ---------------------------------------------------------------------------
Step "Web app $App (Free F1, Linux, .NET 10)"
# list-runtimes prints a table row like "DOTNETCORE|10.0  2028-11-14  Linux ...";
# keep only the first word and write it as DOTNETCORE:10.0 (a "|" breaks az.cmd)
$runtimeRow = az webapp list-runtimes --os linux -o tsv |
    Where-Object { $_ -match '^DOTNETCORE[:|]10' } | Select-Object -First 1
if (-not $runtimeRow) { Fail "Azure did not offer a .NET 10 runtime for Linux web apps." }
$runtime = (($runtimeRow -split '\s+')[0]) -replace '\|', ':'
Write-Host "Runtime: $runtime"

$found = az appservice plan list -g $ResourceGroup --query "[?name=='$Plan'].name" -o tsv
if ($found) {
    Write-Host "Plan already exists."
} else {
    $created = $false
    foreach ($region in $AppLocations) {
        Write-Host "  Trying the free plan in $region..."
        az appservice plan create -g $ResourceGroup -n $Plan -l $region --is-linux --sku F1 -o none 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Created in $region" -ForegroundColor Green
            $created = $true
            break
        }
    }
    if (-not $created) {
        Fail ("No region gave this subscription a free (F1) web app: the F1 quota is 0. " +
              "Request 1 F1 VM in the portal (Quotas > App Service, or Help + support > " +
              "Service and subscription limits), then run this script again.")
    }
}

$found = az webapp list -g $ResourceGroup --query "[?name=='$App'].name" -o tsv
if ($found) {
    Write-Host "Web app already exists."
} else {
    az webapp create -g $ResourceGroup -p $Plan -n $App --runtime $runtime -o none
    Check "create the web app (if the name is taken, run again with another -Name)"
}

Step "Managed identity for the web app (logs in to SQL as itself, no password)"
$principalId = az webapp identity assign -g $ResourceGroup -n $App --query principalId -o tsv
Check "turn on the managed identity"

Step "Web app settings"
$connection = "Server=tcp:$ServerHost,1433;Database=$Database;Authentication=Active Directory Managed Identity;Encrypt=True;Connection Timeout=60;"
az webapp config appsettings set -g $ResourceGroup -n $App --settings `
    "ConnectionStrings__ClinicDb=$connection" `
    "ASPNETCORE_FORWARDEDHEADERS_ENABLED=true" `
    "SCM_DO_BUILD_DURING_DEPLOYMENT=false" -o none
Check "set the connection string"
az webapp config set -g $ResourceGroup -n $App --startup-file "dotnet ClinicApi.dll" -o none
Check "set the startup command"
az webapp update -g $ResourceGroup -n $App --https-only true -o none
Check "turn on HTTPS only"

Step "Database access for the web app (read, write, run procedures)"
$grant = "IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'$App') " +
         "CREATE USER [$App] FROM EXTERNAL PROVIDER WITH OBJECT_ID = '$principalId'; " +
         "ALTER ROLE db_datareader ADD MEMBER [$App]; " +
         "ALTER ROLE db_datawriter ADD MEMBER [$App]; " +
         "GRANT EXECUTE TO [$App];"
Invoke-AzureSql -SqlArgs @("-Q", $grant) -What "give the web app database access" | Out-Null
Write-Host "Done."

# ---------------------------------------------------------------------------
Step "Building and deploying the app"
& "$PSScriptRoot\deploy.ps1" -AppName $App -ResourceGroup $ResourceGroup
if ($LASTEXITCODE -ne 0) { Fail "deploy (see above)" }

Write-Host ""
Write-Host "All set: https://$App.azurewebsites.net" -ForegroundColor Green
Write-Host "The first visit can take up to a minute while the app and database wake up."