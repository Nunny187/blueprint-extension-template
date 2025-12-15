#!/usr/bin/env bash
set -euo pipefail

: "${BP_PANEL_SERVICE:=panel}"
: "${BP_EXTENSION_SLUG:=my-extension}"

# Initialize Blueprint stack (prefer submodule, otherwise clone)
if [ -f "./.gitmodules" ]; then
  git submodule update --init --recursive
elif [ ! -d "./stack" ]; then
  git clone https://github.com/BlueprintFramework/docker stack
fi

# Ensure docker/.env exists
if [ ! -f "./docker/.env" ]; then
  if [ -f "./docker/.env.example" ]; then
    cp ./docker/.env.example ./docker/.env
  else
    echo "Error: docker/.env.example not found. Please create docker/.env." >&2
    exit 1
  fi
fi

# Helper to set or replace a key=value in docker/.env without relying on sed -i
replace_env_var() {
  local key="$1"
  local value="$2"
  if grep -q "^${key}=" ./docker/.env; then
    grep -v "^${key}=" ./docker/.env > ./docker/.env.tmp
    echo "${key}=${value}" >> ./docker/.env.tmp
    mv ./docker/.env.tmp ./docker/.env
  else
    echo "${key}=${value}" >> ./docker/.env
  fi
}

# Ensure BP_HOST_WORKSPACE points at this repo on the host for bind mounts
if ! grep -q "^BP_HOST_WORKSPACE=" ./docker/.env || grep -q "^BP_HOST_WORKSPACE=$" ./docker/.env; then
  REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
  replace_env_var "BP_HOST_WORKSPACE" "${REPO_ROOT}"
  echo "Set BP_HOST_WORKSPACE=${REPO_ROOT}"
fi

# Populate secret values in docker/.env if they are empty or missing
secret_vars=(MARIADB_ROOT_PASS MARIADB_USER_PASS VALKEY_PASS HASH_SALT)
for var in "${secret_vars[@]}"; do
  if ! grep -q "^${var}=" ./docker/.env || grep -Eq "^${var}=[[:space:]]*$" ./docker/.env; then
    random_val=$(openssl rand -base64 32)
    replace_env_var "${var}" "${random_val}"
    echo "Generated ${var}"
  fi
done

# ----------------------------------------------------------------------------- 
# Start the Docker stack
docker compose --env-file ./docker/.env -f ./stack/docker-compose.yml -f ./docker/stack.override.yml up -d

echo "Waiting for panel container to be ready..."
ready=0
for i in $(seq 1 60); do
  if docker compose --env-file ./docker/.env -f ./stack/docker-compose.yml -f ./docker/stack.override.yml exec -T "$BP_PANEL_SERVICE" sh -lc "command -v blueprint >/dev/null 2>&1"; then
    ready=1
    break
  fi
  sleep 2
done

if [ "$ready" -ne 1 ]; then
  echo "Panel did not become ready in time. Check logs with:" >&2
  echo "  docker compose --env-file ./docker/.env -f ./stack/docker-compose.yml -f ./docker/stack.override.yml logs -f" >&2
  exit 1
fi

# ----------------------------------------------------------------------------- 
# Create default development users
docker compose --env-file ./docker/.env -f ./stack/docker-compose.yml -f ./docker/stack.override.yml exec -T "$BP_PANEL_SERVICE" \
  php artisan p:user:make \
    --email="dev@example.com" \
    --username="dev" \
    --name-first="Dev" \
    --name-last="User" \
    --password="dev" \
    --admin=1 || true

docker compose --env-file ./docker/.env -f ./stack/docker-compose.yml -f ./docker/stack.override.yml exec -T "$BP_PANEL_SERVICE" \
  php artisan p:user:make \
    --email="test@example.com" \
    --username="test" \
    --name-first="Test" \
    --name-last="User" \
    --password="test" \
    --admin=0 || true

echo "Created default dev (admin) and test (non-admin) users."
echo "Done."
