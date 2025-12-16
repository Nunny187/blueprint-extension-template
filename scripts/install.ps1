$ErrorActionPreference = "Stop"
. "$PSScriptRoot/common.ps1"

Invoke-Compose @("exec", $env:BP_PANEL_SERVICE, "blueprint", "-i", $env:BP_EXTENSION_SLUG)
