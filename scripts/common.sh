#!/usr/bin/env bash
set -euo pipefail

# Compose file(s) for your stack. Default assumes docker-compose.yml at repo root.
: "${BP_COMPOSE_BASE:=-f docker-compose.yml}"

# Service name of your panel container in compose.
: "${BP_PANEL_SERVICE:=panel}"

# Extension slug/folder name under extensions/
: "${BP_EXTENSION_SLUG:=my-extension}"

# Combine base compose + this repo's override which mounts the extension.
BP_COMPOSE_ARGS="${BP_COMPOSE_BASE} -f docker/stack.override.yml"

dc() {
  # shellcheck disable=SC2086
  docker compose ${BP_COMPOSE_ARGS} "$@"
}
