$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot '../PSFzf.psm1'
Set-Content -Path $scriptPath -Value ('# AUTOGENERATED - DO NOT EDIT' + "`n")
Get-ChildItem (Join-Path $PSScriptRoot '../PSFzf.*.ps1') | ForEach-Object {
    $name = $_.Name
    if ($name -ne 'PSFzf.tests.ps1') {
        Write-Host "Adding $name"
        Add-Content -Path $scriptPath -Value "# $name"
        Get-Content -Path $_ | Add-Content -Path $scriptPath
    }
}
$scriptPath = Resolve-Path $scriptPath
Write-Host "Created $scriptPath"