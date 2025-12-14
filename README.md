# Blueprint Extension Dev Template (Dev Containers)

Reusable template repo for developing Blueprint extensions with:
- VS Code Dev Containers
- A docker-compose override that mounts your extension into the panel container
- Convenience scripts for installing/testing via blueprint inside Docker

## Quick start (VS Code Dev Container)
1. Open this folder in VS Code
2. Run: Dev Containers: Reopen in Container
3. In the devcontainer terminal:

./scripts/up.sh
./scripts/install.sh

## Defaults (override with env vars)
- Main compose file: docker-compose.yml (repo root)
- Panel service name: panel
- Extension slug: my-extension
- Mount path: /srv/pterodactyl/extensions/my-extension

Env overrides:
BP_COMPOSE_BASE   e.g. '-f path/to/stack.yml'
BP_PANEL_SERVICE  default: panel
BP_EXTENSION_SLUG default: my-extension
