BP_COMPOSE_BASE ?= -f stack/docker-compose.yml
BP_PANEL_SERVICE ?= panel
BP_EXTENSION_SLUG ?= my-extension

export BP_COMPOSE_BASE
export BP_PANEL_SERVICE
export BP_EXTENSION_SLUG

BP_COMPOSE_ARGS := $(BP_COMPOSE_BASE) -f docker/stack.override.yml

.PHONY: up down restart logs shell blueprint install bootstrap

bootstrap:
ifeq ($(OS),Windows_NT)
	powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap.ps1
else
	./scripts/bootstrap.sh
endif

up:
	./scripts/up.sh

down:
	./scripts/down.sh

restart: down up

logs:
	docker compose $(BP_COMPOSE_ARGS) logs -f --tail=200

shell:
	docker compose $(BP_COMPOSE_ARGS) exec $(BP_PANEL_SERVICE) sh

blueprint:
	./scripts/blueprint.sh $(ARGS)

install:
	./scripts/install.sh
