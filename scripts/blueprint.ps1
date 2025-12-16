param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Args
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Invoke-Compose (@("exec", $env:BP_PANEL_SERVICE, "blueprint") + $Args)
