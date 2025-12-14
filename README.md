# Blueprint Extension Dev Template (Dev Containers)

Reusable template repo for developing Blueprint extensions with:

- VS Code Dev Containers
- A docker-compose override that mounts your extension into the panel container
- Convenience scripts + Makefile targets for installing/testing via Blueprint CLI in Docker

## Quick start (VS Code Dev Container)

1. Open this folder in VS Code
2. Run: Dev Containers: Reopen in Container
3. In the devcontainer terminal, run:

    make bootstrap

That will bring up the stack and install the extension.

## Common commands

    make up
    make install
    make logs
    make shell

Or without make:

    ./scripts/up.sh
    ./scripts/install.sh
    ./scripts/blueprint.sh -l

## One-command setup (outside devcontainer)

### Windows (PowerShell)

    .\scripts\bootstrap.ps1

### Linux / macOS

    ./scripts/bootstrap.sh

## Defaults (override with env vars)

- Main compose file: stack/docker-compose.yml
- Panel service name: panel
- Extension slug: my-extension
- Mount path: /srv/pterodactyl/extensions/my-extension

Env overrides:

- BP_COMPOSE_BASE (default: -f stack/docker-compose.yml)
- BP_PANEL_SERVICE (default: panel)
- BP_EXTENSION_SLUG (default: my-extension)

## Enable Blueprint Developer Mode

In the panel, go to /admin/extensions, open Blueprint, and enable Developer Mode.
