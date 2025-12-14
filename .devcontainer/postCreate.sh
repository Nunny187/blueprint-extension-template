#!/usr/bin/env bash
set -euo pipefail

echo "Devcontainer ready."
echo ""
echo "Common commands:"
echo "  ./scripts/up.sh         # start your panel stack (uses BP_COMPOSE_BASE)"
echo "  ./scripts/install.sh    # install the extension via blueprint inside the panel"
echo "  ./scripts/blueprint.sh  # run blueprint commands (pass args)"
echo ""
echo "Environment overrides:"
echo "  BP_COMPOSE_BASE     e.g. '-f docker-compose.yml' or '-f stack/docker-compose.yml'"
echo "  BP_PANEL_SERVICE    default: panel"
echo "  BP_EXTENSION_SLUG   default: my-extension"
