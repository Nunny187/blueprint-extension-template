#!/usr/bin/env bash
set -euo pipefail

# This script installs a host-shell alias "blueprint" that runs the CLI inside the panel container.
# It is idempotent: it won’t append duplicates.

source "$(dirname "$0")/common.sh"

# Compose command should run from the repo root so relative -f paths resolve.
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

ALIAS_CMD="cd \"${REPO_ROOT}\" && docker compose"
if [ -f "${REPO_ROOT}/${BP_ENV_FILE#./}" ]; then
  ALIAS_CMD="${ALIAS_CMD} --env-file \"${BP_ENV_FILE}\""
fi
ALIAS_CMD="${ALIAS_CMD} ${BP_COMPOSE_ARGS} exec ${BP_PANEL_SERVICE} blueprint"

ALIAS_LINE="alias blueprint='${ALIAS_CMD}'"

# Pick a shell rc file to modify
RC_FILE=""
if [ -n "${ZSH_VERSION:-}" ]; then
  RC_FILE="${HOME}/.zshrc"
else
  RC_FILE="${HOME}/.bashrc"
fi

# Ensure file exists
touch "${RC_FILE}"

# Avoid duplicates
if grep -Fqx "${ALIAS_LINE}" "${RC_FILE}"; then
  echo "blueprint alias already present in ${RC_FILE}"
else
  {
    echo ""
    echo "# Blueprint CLI (project alias)"
    echo "${ALIAS_LINE}"
  } >> "${RC_FILE}"
  echo "Added blueprint alias to ${RC_FILE}"
fi

echo ""
echo "To use it in your current shell:"
echo "  source \"${RC_FILE}\""
echo ""
echo "Test:"
echo "  blueprint -v"
