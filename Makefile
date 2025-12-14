# Defaults (override like: make up BP_EXTENSION_SLUG=my-ext)
BP_COMPOSE_BASE ?= -f docker-compose.yml
BP_PANEL_SERVICE ?= panel
BP_EXTENSION_SLUG ?= my-extension

export BP_COMPOSE_BASE
export BP_PANEL_SERVICE
export BP_EXTENSION_SLUG

.PHONY: up down restart logs shell blueprint install

up:
	./scripts/up.sh

down:
	./scripts/down.sh

restart: down up

logs:
	docker compose $(BP_COMPOSE_BASE) logs -f --tail=200

shell:
	docker compose $(BP_COMPOSE_BASE) exec $(BP_PANEL_SERVICE) sh

blueprint:
	./scripts/blueprint.sh $(ARGS)

install:
	./scripts/install.sh
