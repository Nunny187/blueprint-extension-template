$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Invoke-Compose @("down")
