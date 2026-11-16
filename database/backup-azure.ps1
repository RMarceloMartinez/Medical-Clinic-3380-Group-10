# backup-azure.ps1
# Writes a full SQL dump of the Azure MedicalClinic database (tables, rows, views,
# procedures, triggers) into ONE .sql file that rebuilds it on SQL Server Express.
#
# Order in the file: tables -> rows -> functions/views/procedures -> triggers.
# Triggers go last so that loading old rows can't trip today's rules
# (for example, a past visit whose referral is no longer open).
#
# Needs: the SqlServer PowerShell module and "az login" done in this window.

param(
    [string]$Server   = 'clinic3380-rm-sql.database.windows.net',
    [string]$Database = 'MedicalClinic',
    [string]$OutFile  = 'C:\Projects\Submission\MedicalClinic_dump.sql'
)

$ErrorActionPreference = 'Stop'
Import-Module SqlServer

# 1. Sign in to Azure SQL with your az login (Microsoft Entra, no password)
$token = az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv
if (-not $token) { throw 'No Azure token. Run "az login" first.' }

Write-Host "Connecting to $Server / $Database (can take a minute if it was paused)..."
$db  = Get-SqlDatabase -ServerInstance $Server -Name $Database -AccessToken $token
$srv = $db.Parent
$srv.ConnectionContext.StatementTimeout = 600

New-Item -ItemType Directory -Force -Path (Split-Path $OutFile) | Out-Null

# Same settings for every pass. $append = $false only for the first pass (starts a new file).
function New-Scripter([bool]$append) {
    $s = New-Object Microsoft.SqlServer.Management.Smo.Scripter($srv)
    $o = $s.Options
    $o.FileName              = $OutFile
    $o.ToFileOnly            = $true
    $o.AppendToFile          = $append
    $o.Encoding              = [System.Text.Encoding]::UTF8
    $o.ScriptBatchTerminator = $true      # GO between statements
    $o.IncludeHeaders        = $false
    $o.NoCollation           = $true
    $o.TargetServerVersion      = [Microsoft.SqlServer.Management.Smo.SqlServerVersion]::Version160      # SQL Server 2022
    $o.TargetDatabaseEngineType = [Microsoft.SqlServer.Management.Common.DatabaseEngineType]::Standalone # SQL Server Express, not Azure
    return $s
}

function UrnsOf($objects) {
    # The leading comma keeps PowerShell from unrolling the array, so EnumScript gets a typed Urn[]
    return ,([Microsoft.SqlServer.Management.Sdk.Sfc.Urn[]]@($objects | ForEach-Object { $_.Urn }))
}

$tables = @($db.Tables | Where-Object { -not $_.IsSystemObject })
$tableUrns = UrnsOf $tables

# Pass 1: tables with primary/foreign keys, CHECK and UNIQUE constraints, indexes (no triggers yet)
$s = New-Scripter $false
$s.Options.WithDependencies = $true   # parent tables before child tables (foreign keys)
$s.Options.DriAll           = $true
$s.Options.Indexes          = $true   # includes the filtered unique indexes (SSN, one primary doctor...)
$s.Options.Triggers         = $false
$s.EnumScript($tableUrns) | Out-Null
Write-Host "1/4 Tables: $($tables.Count)"

# Pass 2: every row as INSERTs, in the same parent-first order (keeps the IDs)
$s = New-Scripter $true
$s.Options.WithDependencies = $true
$s.Options.ScriptSchema     = $false
$s.Options.ScriptData       = $true
$s.EnumScript($tableUrns) | Out-Null
Write-Host '2/4 Rows done'

# Pass 3: functions, then views (a view that uses another view comes after it), then procedures
$functions = @($db.UserDefinedFunctions | Where-Object { -not $_.IsSystemObject })
if ($functions.Count) { (New-Scripter $true).EnumScript((UrnsOf $functions)) | Out-Null }

$views = @($db.Views | Where-Object { -not $_.IsSystemObject })
if ($views.Count) {
    $walker = New-Object Microsoft.SqlServer.Management.Smo.DependencyWalker($srv)
    $tree   = $walker.DiscoverDependencies([Microsoft.SqlServer.Management.Smo.SqlSmoObject[]]$views, $true)
    $viewUrns = [Microsoft.SqlServer.Management.Sdk.Sfc.Urn[]]@(
        $walker.WalkDependencies($tree) | Where-Object { $_.Urn.Type -eq 'View' } | ForEach-Object { $_.Urn })
    (New-Scripter $true).EnumScript($viewUrns) | Out-Null
}

$procedures = @($db.StoredProcedures | Where-Object { -not $_.IsSystemObject })
if ($procedures.Count) { (New-Scripter $true).EnumScript((UrnsOf $procedures)) | Out-Null }
Write-Host "3/4 Functions: $($functions.Count), views: $($views.Count), procedures: $($procedures.Count)"

# Pass 4: triggers, last
$triggers = @($tables | ForEach-Object { $_.Triggers })
if ($triggers.Count) { (New-Scripter $true).EnumScript((UrnsOf $triggers)) | Out-Null }
Write-Host "4/4 Triggers: $($triggers.Count)"

$size = [math]::Round((Get-Item $OutFile).Length / 1KB)
Write-Host "Done: $OutFile ($size KB)"
