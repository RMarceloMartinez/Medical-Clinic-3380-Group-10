# Builds the React site + API into one package and uploads it to the Azure web app.
# Use it every time you want the live site to show your latest code.
#
# Run from the repo root AFTER `az login`:
#   powershell -ExecutionPolicy Bypass -File deploy.ps1 -AppName clinic3380-rm

param(
    [Parameter(Mandatory = $true)][string]$AppName,
    [string]$ResourceGroup = "clinic-rg"
)

$ErrorActionPreference = "Continue"

function Step($text) { Write-Host ""; Write-Host "--> $text" -ForegroundColor Cyan }
function Fail($text) { Write-Host "STOPPED: $text" -ForegroundColor Red; exit 1 }
function Check($what) { if ($LASTEXITCODE -ne 0) { Fail $what } }

Push-Location $PSScriptRoot
try {
    Step "1/4 Building the React site (frontend\dist)"
    Push-Location frontend
    npm install --no-audit --no-fund
    Check "npm install"
    npm run build
    Check "npm run build"
    Pop-Location

    Step "2/4 Publishing the API (publish\)"
    if (Test-Path publish) { Remove-Item publish -Recurse -Force }
    dotnet publish backend -c Release -o publish
    Check "dotnet publish"

    Step "3/4 Putting the site in wwwroot and zipping (app.zip)"
    New-Item publish\wwwroot -ItemType Directory -Force | Out-Null
    Copy-Item frontend\dist\* publish\wwwroot -Recurse -Force
    if (Test-Path app.zip) { Remove-Item app.zip -Force }
    # tar (built into Windows 10/11) writes zip paths with "/" so they unpack correctly on Linux
    tar.exe -a -c -f app.zip -C publish .
    Check "create app.zip"

    Step "4/4 Uploading to Azure (takes a minute or two)"
    az webapp deploy -g $ResourceGroup -n $AppName --src-path app.zip --type zip -o none
    Check "az webapp deploy"

    Write-Host ""
    Write-Host "Deployed: https://$AppName.azurewebsites.net" -ForegroundColor Green
}
finally {
    Pop-Location
}