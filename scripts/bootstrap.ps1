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

Write-Host "Done. Your dev stack should be up and your extension installed." -ForegroundColor Green