<#
  Windows PowerShell script to bootstrap the Blueprint development environment.

  This script mirrors the behaviour of the Bash `bootstrap.sh` script. It
  initializes any Git submodules or clones the Blueprint Docker stack if
  necessary, starts the docker compose stack with the appropriate override
  configuration, installs the extension using the Blueprint CLI, and creates
  default development users for convenience.
  
  Two users are created:
    - dev  (admin=1, password "dev")
    - test (admin=0, password "test")

  Running this script multiple times is idempotent. If the users already exist
  the creation commands will emit an error which is safely ignored.
#>

$ErrorActionPreference = "Stop"

# Config (override by setting env vars before running)
if (-not $env:BP_PANEL_SERVICE) { $env:BP_PANEL_SERVICE = "panel" }
if (-not $env:BP_EXTENSION_SLUG) { $env:BP_EXTENSION_SLUG = "my-extension" }

# Ensure submodule is initialized (preferred over git clone)
if (Test-Path ".\.gitmodules") {
    git submodule update --init --recursive
}
elseif (-not (Test-Path ".\stack")) {
    git clone https://github.com/BlueprintFramework/docker stack
}

# Ensure env file exists (create from example if available)
if (-not (Test-Path ".\stack\.env")) {
    if (Test-Path ".\stack\.env.example") {
        Copy-Item ".\stack\.env.example" ".\stack\.env"
    }
    else {
        Write-Host "Warning: stack\.env (or .env.example) not found. You may need to create/configure it." -ForegroundColor Yellow
    }
}

# Bring up stack with your override
docker compose -f .\stack\docker-compose.yml -f .\docker\stack.override.yml up -d

# Wait for Blueprint CLI to be available in the panel container
Write-Host "Waiting for panel container to be ready..." -ForegroundColor Cyan
$ready = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        docker compose -f .\stack\docker-compose.yml -f .\docker\stack.override.yml `
            exec -T $env:BP_PANEL_SERVICE sh -lc "command -v blueprint >/dev/null 2>&1" | Out-Null
        $ready = $true
        break
    }
    catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $ready) {
    Write-Host "Panel did not become ready in time. Check logs with: docker compose -f .\stack\docker-compose.yml logs -f" -ForegroundColor Red
    exit 1
}

# Install extension via Blueprint CLI in panel container
docker compose -f .\stack\docker-compose.yml -f .\docker\stack.override.yml `
    exec -T $env:BP_PANEL_SERVICE blueprint -i $env:BP_EXTENSION_SLUG

# -----------------------------------------------------------------------------
# Create default development users (dev/admin and test)
#
# Use the Pterodactyl Artisan CLI to generate accounts. These commands may
# produce errors if the users already exist; these are caught and ignored so
# subsequent runs do not fail.
try {
    docker compose -f .\stack\docker-compose.yml -f .\docker\stack.override.yml `
        exec -T $env:BP_PANEL_SERVICE php artisan p:user:make `
        --email="dev@example.com" `
        --username="dev" `
        --name-first="Dev" `
        --name-last="User" `
        --password="dev" `
        --admin=1 | Out-Null
    docker compose -f .\stack\docker-compose.yml -f .\docker\stack.override.yml `
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