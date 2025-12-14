$ErrorActionPreference = "Stop"

# Config (override by setting env vars before running)
if (-not $env:BP_PANEL_SERVICE) { $env:BP_PANEL_SERVICE = "panel" }
if (-not $env:BP_EXTENSION_SLUG) { $env:BP_EXTENSION_SLUG = "my-extension" }

# Ensure stack exists
if (-not (Test-Path ".\stack")) {
    git clone https://github.com/BlueprintFramework/docker stack
}

# Ensure env file exists (stack uses .env for the recommended compose flow)
if (-not (Test-Path ".\stack\.env")) {
    if (Test-Path ".\stack\.env.example") {
        Copy-Item ".\stack\.env.example" ".\stack\.env"
    }
    else {
        Write-Host "Warning: stack/.env (or .env.example) not found. You may need to create/configure it."
    }
}

# Bring up stack with your override
docker compose -f .\stack\docker-compose.yml -f .\docker\stack.override.yml up -d

# Install extension via Blueprint CLI in panel container
docker compose -f .\stack\docker-compose.yml -f .\docker\stack.override.yml exec $env:BP_PANEL_SERVICE blueprint -i $env:BP_EXTENSION_SLUG

Write-Host "Done. Your dev stack should be up and your extension installed."