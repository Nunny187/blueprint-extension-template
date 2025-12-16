<#
  Windows PowerShell script to bootstrap the Blueprint development environment.

  Mirrors the Bash bootstrap: initializes the Blueprint Docker stack, ensures
  configuration exists, starts the stack with overrides, and creates default
  dev users.
#>

$ErrorActionPreference = "Stop"

# Helper to generate base64 secrets without external dependencies
function New-RandomBase64($bytes = 32) {
    $buffer = New-Object byte[] $bytes
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($buffer)
    [Convert]::ToBase64String($buffer)
}

# Config (override via env vars)
if (-not $env:BP_PANEL_SERVICE) { $env:BP_PANEL_SERVICE = "panel" }
if (-not $env:BP_EXTENSION_SLUG) { $env:BP_EXTENSION_SLUG = "my-extension" }

# Initialize Blueprint stack (prefer submodule)
if (Test-Path ".\.gitmodules") {
    git submodule update --init --recursive
}
elseif (-not (Test-Path ".\stack")) {
    git clone https://github.com/BlueprintFramework/docker stack
}

# Ensure docker\.env exists
if (-not (Test-Path ".\docker\.env")) {
    if (Test-Path ".\docker\.env.example") {
        Copy-Item ".\docker\.env.example" ".\docker\.env"
    }
    else {
        Write-Host "Error: docker\.env.example not found. Please create docker\.env." -ForegroundColor Red
        exit 1
    }
}

# Ensure BP_HOST_WORKSPACE points at this repo on the host for bind mounts
$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path -replace "\\", "/"
$envContent = Get-Content ".\docker\.env"
if ($envContent -notmatch "^BP_HOST_WORKSPACE=" -or $envContent -match "^BP_HOST_WORKSPACE=$") {
    if ($envContent -match "^BP_HOST_WORKSPACE=") {
        (Get-Content ".\docker\.env") -replace "^BP_HOST_WORKSPACE=.*$", "BP_HOST_WORKSPACE=$repoRoot" | Set-Content ".\docker\.env"
    }
    else {
        Add-Content ".\docker\.env" "BP_HOST_WORKSPACE=$repoRoot"
    }
    Write-Host "Set BP_HOST_WORKSPACE=$repoRoot"
}

# Populate secret values in docker\.env
$secretVars = @("MARIADB_ROOT_PASS", "MARIADB_USER_PASS", "VALKEY_PASS", "HASH_SALT")
foreach ($var in $secretVars) {
    $envContent = Get-Content ".\docker\.env"
    if ($envContent -notmatch "^$var=" -or $envContent -match "^$var=$") {
        $randomVal = New-RandomBase64 32
        if ($envContent -match "^$var=") {
            (Get-Content ".\docker\.env") -replace "^$var=.*$", "$var=$randomVal" | Set-Content ".\docker\.env"
        }
        else {
            Add-Content ".\docker\.env" "$var=$randomVal"
        }
        Write-Host "Generated $var"
    }
}

# ----------------------------------------------------------------------------- 
# Bring up docker stack with override
docker compose --env-file .\docker\.env -f .\stack\docker-compose.yml -f .\docker\stack.override.yml up -d

# Wait for Blueprint CLI to be available in the panel container
Write-Host "Waiting for panel container to be ready..." -ForegroundColor Cyan
$ready = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        docker compose --env-file .\docker\.env -f .\stack\docker-compose.yml -f .\docker\stack.override.yml `
            exec -T $env:BP_PANEL_SERVICE sh -lc "command -v blueprint >/dev/null 2>&1" | Out-Null
        $ready = $true
        break
    }
    catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $ready) {
    Write-Host "Panel did not become ready in time. Check logs with: docker compose --env-file .\docker\.env -f .\stack\docker-compose.yml -f .\docker\stack.override.yml logs -f" -ForegroundColor Red
    exit 1
}

# ----------------------------------------------------------------------------- 
# Create default development users (dev/admin and test)
try {
    docker compose --env-file .\docker\.env -f .\stack\docker-compose.yml -f .\docker\stack.override.yml `
        exec -T $env:BP_PANEL_SERVICE php artisan p:user:make `
        --email="dev@example.com" `
        --username="dev" `
        --name-first="Dev" `
        --name-last="User" `
        --password="dev" `
        --admin=1 | Out-Null
    docker compose --env-file .\docker\.env -f .\stack\docker-compose.yml -f .\docker\stack.override.yml `
        exec -T $env:BP_PANEL_SERVICE php artisan p:user:make `
        --email="test@example.com" `
        --username="test" `
        --name-first="Test" `
        --name-last="User" `
        --password="test" `
        --admin=0 | Out-Null
    Write-Host "Created default dev (admin) and test (non-admin) users." -ForegroundColor Green
}
catch {
    Write-Host "Failed to create default users. They might already exist." -ForegroundColor Yellow
}

Write-Host "Done. Your dev stack should be up, your extension installed, and default users created." -ForegroundColor Green
