#!/usr/bin/env bash
set -euo pipefail

# Default panel service name (can be overridden by setting BP_PANEL_SERVICE env var)
: "${BP_PANEL_SERVICE:=panel}"
# Default extension slug (can be overridden by setting BP_EXTENSION_SLUG env var)
: "${BP_EXTENSION_SLUG:=my-extension}"

# Prefer submodule init/update if this repo uses submodules. Otherwise clone
# the Blueprint docker stack into the local ./stack directory. This ensures
# that all required containers and configuration are available for the dev
# environment.
if [ -f "./.gitmodules" ]; then
  git submodule update --init --recursive
elif [ ! -d "./stack" ]; then
  git clone https://github.com/BlueprintFramework/docker stack
fi

# Ensure docker/.env exists – copy from example if missing
if [ ! -f "./docker/.env" ]; then
  if [ -f "./docker/.env.example" ]; then
    cp ./docker/.env.example ./docker/.env
  else
    echo "Error: docker/.env.example not found. Please create a docker/.env file." >&2
    exit 1
  fi
fi

# Populate secret values in docker/.env if they are empty or commented out
secret_vars=(MARIADB_ROOT_PASS MARIADB_USER_PASS VALKEY_PASS HASH_SALT)
for var in "${secret_vars[@]}"; do
  if grep -q "^${var}=" ./docker/.env; then
    # Key exists; check if value is empty
    if grep -q "^${var}=$" ./docker/.env; then
      random_val=$(openssl rand -base64 32)
      # Replace only a blank value
      sed -i "s/^${var}=$/${var}=${random_val}/" ./docker/.env
      echo "Filled ${var}"
    fi
  else
    # Key does not exist; append a new line
    random_val=$(openssl rand -base64 32)
    echo "${var}=${random_val}" >> ./docker/.env
    echo "Added ${var}"
  fi
done
# -----------------------------------------------------------------------------
# Start the Docker stack

# Bring up the docker stack with our override that mounts the extension into
# the panel container. The --detach flag returns immediately while the
# containers are starting.
docker compose --env-file ./docker/.env -f ./stack/docker-compose.yml -f ./docker/stack.override.yml up -d

echo "Waiting for panel container to be ready..."
ready=0
for i in $(seq 1 60); do
  # Test for the presence of the Blueprint CLI inside the panel container. Once
  # the CLI is available we know the panel has finished its bootstrapping.
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

# -----------------------------------------------------------------------------
# Create default development users
#
# To make it easy to log into the panel for development we automatically
# generate two accounts:
#   * dev  – Admin user with password "dev"
#   * test – Non‑admin user with password "test"
#
# We use the Pterodactyl artisan CLI to create users. If the user already
# exists the command will exit with a non‑zero status. We append `|| true`
# to ensure the script continues even if users are already present.

docker compose -f ./stack/docker-compose.yml -f ./docker/stack.override.yml exec -T "$BP_PANEL_SERVICE" \
  php artisan p:user:make \
    --email="dev@example.com" \
    --username="dev" \
    --name-first="Dev" \
    --name-last="User" \
    --password="dev" \
    --admin=1 || true

docker compose -f ./stack/docker-compose.yml -f ./docker/stack.override.yml exec -T "$BP_PANEL_SERVICE" \
  php artisan p:user:make \
    --email="test@example.com" \
    --username="test" \
    --name-first="Test" \
    --name-last="User" \
    --password="test" \
    --admin=0 || true

echo "Created default dev (admin) and test (non‑admin) users."

echo "Done."