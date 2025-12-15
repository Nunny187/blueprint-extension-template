### Blueprint Extension Development Environment

This repository ships a lightweight Blueprint Docker stack plus helper scripts so you can build and test extensions locally.

## Quick start
- Clone the repo and `cd` into it.
- Run the bootstrap script for your platform:
  - Linux/macOS: `./scripts/bootstrap.sh`
  - Windows PowerShell: `./scripts/bootstrap.ps1`
- The script will clone/update the Blueprint stack, copy `docker/.env` from the example if needed, set `BP_HOST_WORKSPACE` to this repo path, generate missing secrets, start Docker, and create two users (dev/admin with password `dev`, test/non-admin with password `test`).
- Visit `https://localhost` (or the host/port in `docker/.env`), log in as `dev`, go to `/admin/extensions`, select Blueprint, and set developer to true (once).

## Working on your extension
- Code lives in `extension/` in this repo. It is bind-mounted into the panel at `/app/.blueprint/dev` via `docker/stack.override.yml`.
- If you move the repo, update `BP_HOST_WORKSPACE` in `docker/.env` to the new absolute path, then rerun:
  - `docker compose --env-file docker/.env -f stack/docker-compose.yml -f docker/stack.override.yml up -d`
- Run Blueprint CLI inside the panel container:
  - `docker compose --env-file docker/.env -f stack/docker-compose.yml -f docker/stack.override.yml exec panel blueprint -v`
- To scaffold an extension from a template:
  - `docker compose --env-file docker/.env -f stack/docker-compose.yml -f docker/stack.override.yml exec panel blueprint -init`

## Environment variables

| Variable             | Default Value                              | Description                                                               |
| -------------------- | ------------------------------------------ | ------------------------------------------------------------------------- |
| BP_HOST_WORKSPACE    | repo path detected by bootstrap scripts    | Absolute host path used to bind-mount `extension/` into the panel         |
| BP_PANEL_SERVICE     | panel                                      | Name of the service running the Pterodactyl panel                         |
| BP_EXTENSION_SLUG    | my-extension                               | Folder name of your extension under `extension/`                          |

Override when invoking scripts, e.g. `BP_EXTENSION_SLUG=recolor ./scripts/bootstrap.sh`.

## Optional: host alias for `blueprint`

If you want to run `blueprint ...` directly on your host (without typing `docker compose ...`), run:

```
make alias
source ~/.bashrc   # or ~/.zshrc
blueprint -v
```
