#!/usr/bin/env bash
set -euo pipefail

echo "Devcontainer ready."
echo ""
echo "Common command:"
echo "  ./scripts/bootstrap.sh  # bootstrap the panel and create dev users"
echo ""
echo "Environment overrides:"
echo "  BP_COMPOSE_BASE     e.g. '-f docker-compose.yml' or '-f stack/docker-compose.yml'"
echo "  BP_PANEL_SERVICE    default: panel"
echo "  BP_EXTENSION_SLUG   default: my-extension"
