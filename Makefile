BP_COMPOSE_BASE ?= -f stack/docker-compose.yml
BP_PANEL_SERVICE ?= panel
BP_EXTENSION_SLUG ?= my-extension

export BP_COMPOSE_BASE
export BP_PANEL_SERVICE
export BP_EXTENSION_SLUG

BP_COMPOSE_ARGS := $(BP_COMPOSE_BASE) -f docker/stack.override.yml

.PHONY: up down restart logs shell blueprint install bootstrap doctor alias

ifeq ($(OS),Windows_NT)
PS_CMD := powershell -ExecutionPolicy Bypass -File
BOOTSTRAP_CMD := $(PS_CMD) ./scripts/bootstrap.ps1
UP_CMD := $(PS_CMD) ./scripts/up.ps1
DOWN_CMD := $(PS_CMD) ./scripts/down.ps1
LOGS_CMD := $(PS_CMD) ./scripts/logs.ps1
SHELL_CMD := $(PS_CMD) ./scripts/shell.ps1
BLUEPRINT_CMD := $(PS_CMD) ./scripts/blueprint.ps1 $(ARGS)
INSTALL_CMD := $(PS_CMD) ./scripts/install.ps1
ALIAS_CMD := $(PS_CMD) ./scripts/alias-blueprint.ps1
else
BOOTSTRAP_CMD := ./scripts/bootstrap.sh
UP_CMD := ./scripts/up.sh
DOWN_CMD := ./scripts/down.sh
LOGS_CMD := docker compose $(BP_COMPOSE_ARGS) logs -f --tail=200
SHELL_CMD := docker compose $(BP_COMPOSE_ARGS) exec $(BP_PANEL_SERVICE) sh
BLUEPRINT_CMD := ./scripts/blueprint.sh $(ARGS)
INSTALL_CMD := ./scripts/install.sh
ALIAS_CMD := ./scripts/alias-blueprint.sh
endif

bootstrap:
	$(BOOTSTRAP_CMD)

alias:
	$(ALIAS_CMD)

up:
	$(UP_CMD)

down:
	$(DOWN_CMD)

restart: down up

logs:
	$(LOGS_CMD)

shell:
	$(SHELL_CMD)

blueprint:
	$(BLUEPRINT_CMD)

install:
	$(INSTALL_CMD)

doctor:
	@echo BP_COMPOSE_BASE=$(BP_COMPOSE_BASE)
	@echo BP_PANEL_SERVICE=$(BP_PANEL_SERVICE)
	@echo BP_EXTENSION_SLUG=$(BP_EXTENSION_SLUG)
