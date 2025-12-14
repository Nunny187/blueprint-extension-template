#!/usr/bin/env bash
set -euo pipefail

: "${BP_PANEL_SERVICE:=panel}"
: "${BP_EXTENSION_SLUG:=my-extension}"

# Prefer submodule init/update if this repo uses submodules
if [ -f "./.gitmodules" ]; then
  git submodule update --init --recursive
elif [ ! -d "./stack" ]; then
  git clone https://github.com/BlueprintFramework/docker stack
fi

# Ensure env file exists (create from example if available)
if [ ! -f "./stack/.env" ] && [ -f "./stack/.env.example" ]; then
  cp ./stack/.env.example ./stack/.env
elif [ ! -f "./stack/.env" ]; then
  echo "Warning: stack/.env (or .env.example) not found. You may need to create/configure it." >&2
fi

docker compose -f ./stack/docker-compose.yml -f ./docker/stack.override.yml up -d

echo "Waiting for panel container to be ready..."
ready=0
for i in $(seq 1 60); do
  if docker compose -f ./stack/docker-compose.yml -f ./docker/stack.override.yml exec -T "$BP_PANEL_SERVICE" sh -lc "command -v blueprint >/dev/null 2>&1"; then
    ready=1
    break
  fi
  sleep 2
done

if [ "$ready" -ne 1 ]; then
  echo "Panel did not become ready in time. Check logs with:" >&2
  echo "  docker compose -f ./stack/docker-compose.yml -f ./docker/stack.override.yml logs -f" >&2
  exit 1
fi

docker compose -f ./stack/docker-compose.yml -f ./docker/stack.override.yml exec -T "$BP_PANEL_SERVICE" blueprint -i "$BP_EXTENSION_SLUG"

echo "Done."