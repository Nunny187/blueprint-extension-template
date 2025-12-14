#!/usr/bin/env bash
set -euo pipefail

: "${BP_PANEL_SERVICE:=panel}"
: "${BP_EXTENSION_SLUG:=my-extension}"

if [ ! -d "./stack" ]; then
  git clone https://github.com/BlueprintFramework/docker stack
fi

if [ ! -f "./stack/.env" ] && [ -f "./stack/.env.example" ]; then
  cp ./stack/.env.example ./stack/.env
fi

docker compose -f ./stack/docker-compose.yml -f ./docker/stack.override.yml up -d
docker compose -f ./stack/docker-compose.yml -f ./docker/stack.override.yml exec "$BP_PANEL_SERVICE" blueprint -i "$BP_EXTENSION_SLUG"

echo "Done."
