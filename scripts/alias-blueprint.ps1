$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

$profilePath = $PROFILE
$profileDir = Split-Path $profilePath
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$blueprintScript = (Resolve-Path "$PSScriptRoot/blueprint.ps1").Path
$profileContent = if (Test-Path $profilePath) { Get-Content $profilePath -Raw } else { "" }

$marker = "Blueprint CLI alias ($blueprintScript)"

if ($profileContent -notmatch [Regex]::Escape($marker)) {
    $snippet = @"
# $marker
function blueprint {
    param(
        [Parameter(ValueFromRemainingArguments=`$true)]
        [string[]] `$Args
    )
    & "$blueprintScript" @`$Args
}
Set-Alias bp blueprint
"@
    Add-Content -Path $profilePath -Value $snippet
    Write-Host "Added blueprint function + bp alias to $profilePath"
    Write-Host "Reload your profile for this session: . `"$profilePath`""
} else {
    Write-Host "Blueprint alias already present in $profilePath"
}
