### Blueprint Extension Development Environment

This repository provides a simplified template for developing Blueprint
extensions against a local Pterodactyl panel. It packages the official Blueprint Docker stack together with a set of helper scripts to make getting started easy.

## Quick start

Clone this repository and run the bootstrap script appropriate for your platform:

# On Linux or macOS

./scripts/bootstrap.sh

# On Windows (PowerShell)

./scripts/bootstrap.ps1

The script will:

Ensure the Blueprint Docker stack is available (via submodules or a fresh clone).

Copy the example .env file if necessary so you can configure ports and credentials.

Bring up the docker-compose stack with the extension mounted into the panel container.

Install your extension via the Blueprint CLI (using the BP_EXTENSION_SLUG environment variable; default my-extension).

Automatically create two development accounts:

dev — password dev, admin privileges (--admin=1)

test — password test, regular user (--admin=0)

After the script completes, open your browser to https://localhost (or whatever domain/port you configured) and log in with either of the accounts above. You can then begin working on your extension inside the extension/ folder, and changes will reflect inside the running panel.

## Environment variables

The bootstrap scripts honour the following environment variables to let you customise the build:

| Variable          | Default Value | Description                                                               |
| ----------------- | ------------- | ------------------------------------------------------------------------- |
| BP_PANEL_SERVICE  | panel         | Name of the service running the Pterodactyl panel within the compose file |
| BP_EXTENSION_SLUG | my-extension  | Folder name of your extension under `extension/`                          |

You can override these variables when invoking the scripts, e.g.:

BP_EXTENSION_SLUG=recolor ./scripts/bootstrap.sh

## Notes

This repository is a trimmed down example focusing on the bootstrapping logic and user creation. Refer to the official Blueprint documentation for more comprehensive guides on extension development and advanced Docker usage.
