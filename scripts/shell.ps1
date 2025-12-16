$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Invoke-Compose @("exec", $env:BP_PANEL_SERVICE, "sh")
