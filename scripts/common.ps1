#requires -Version 5.1
$ErrorActionPreference = "Stop"

# Repository root (scripts live in repo/scripts)
$script:RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path

function Resolve-RepoPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    return (Join-Path $script:RepoRoot $Path)
}

# Defaults mirroring common.sh
if (-not $env:BP_ENV_FILE) { $env:BP_ENV_FILE = "docker/.env" }
if (-not $env:BP_COMPOSE_BASE) { $env:BP_COMPOSE_BASE = "-f stack/docker-compose.yml" }
if (-not $env:BP_PANEL_SERVICE) { $env:BP_PANEL_SERVICE = "panel" }
if (-not $env:BP_EXTENSION_SLUG) { $env:BP_EXTENSION_SLUG = "my-extension" }

$script:EnvFilePath = Resolve-RepoPath $env:BP_ENV_FILE

# Split compose base args and resolve -f paths relative to repo
$composeBaseArgs = @()
$rawBaseArgs = $env:BP_COMPOSE_BASE -split "\s+"
for ($i = 0; $i -lt $rawBaseArgs.Count; $i++) {
    $arg = $rawBaseArgs[$i]
    $composeBaseArgs += $arg
    if ($arg -eq "-f" -and ($i + 1) -lt $rawBaseArgs.Count) {
        $i++
        $composeBaseArgs += (Resolve-RepoPath $rawBaseArgs[$i])
    }
}

$composeOverrideArgs = @("-f", (Resolve-RepoPath "docker/stack.override.yml"))
$script:ComposeArgs = $composeBaseArgs + $composeOverrideArgs

function Invoke-Compose {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Args
    )

    Push-Location $script:RepoRoot
    try {
        $cmd = @("docker", "compose")
        if (Test-Path $script:EnvFilePath) {
            $cmd += @("--env-file", $script:EnvFilePath)
        }
        $cmd += $script:ComposeArgs
        $cmd += $Args
        & $cmd
    }
    finally {
        Pop-Location
    }
}
