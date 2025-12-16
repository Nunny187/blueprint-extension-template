$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Invoke-Compose @("logs", "-f", "--tail=200")
