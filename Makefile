# SkillBucket root Makefile
# Usage: make help

SHELL := /bin/bash
.DEFAULT_GOAL := help

# --- config ---
COMPOSE ?= docker compose
WEB_DIR ?= apps/web
API_DIR ?= apps/api
WORKER_DIR ?= apps/worker
PKG_DIRS ?= packages/framework_ingest packages/rag packages/shared/python

# Detect pnpm, fallback to npm
NODE_PM := $(shell command -v pnpm >/dev/null 2>&1 && echo pnpm || echo npm)

# uv executable (assumes installed)
UV ?= uv

# Common env file
ENV_FILE ?= .env

# --- includes (optional; keep everything in one file if you prefer) ---
# -include make/dev.mk
# -include make/python.mk
# -include make/web.mk
# -include make/gen.mk
# -include make/data.mk

# --- help ---
.PHONY: help
help:
	@awk 'BEGIN {FS=":.*##"; printf "\nTargets:\n"} /^[a-zA-Z0-9_.-]+:.*##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# --- bootstrap ---
.PHONY: bootstrap
bootstrap: ## One-time setup: create .env, install deps, bring stack up
	@[ -f "$(ENV_FILE)" ] || (cp .env.example $(ENV_FILE) && echo "Created $(ENV_FILE)")
	@$(MAKE) install
	@$(MAKE) up

.PHONY: env
env: ## Show key tool choices (uv + node package manager)
	@echo "uv:      $(UV)"
	@echo "node pm: $(NODE_PM)"
	@echo "compose: $(COMPOSE)"

# --- docker/stack ---
.PHONY: up
up: ## Start dev stack (postgres/qdrant/minio/etc) via compose
	$(COMPOSE) -f infra/compose.yaml up -d

.PHONY: down
down: ## Stop dev stack
	$(COMPOSE) -f infra/compose.yaml down

.PHONY: restart
restart: ## Restart dev stack
	$(MAKE) down
	$(MAKE) up

.PHONY: logs
logs: ## Tail logs for dev stack
	$(COMPOSE) -f infra/compose.yaml logs -f

.PHONY: ps
ps: ## Show running containers
	$(COMPOSE) -f infra/compose.yaml ps

.PHONY: nuke
nuke: ## Remove containers + volumes (DELETES local DB/vector data)
	$(COMPOSE) -f infra/compose.yaml down -v

# --- installs ---
.PHONY: install
install: install-py install-web ## Install python + web deps

.PHONY: install-py
install-py: ## Install python deps for api (+ worker) and editable local packages
	$(UV) sync --project $(API_DIR)
	@if [ -d "$(WORKER_DIR)" ]; then $(UV) sync --project $(WORKER_DIR); fi
	@$(MAKE) install-packages

.PHONY: install-packages
install-packages: ## Install local packages in editable mode into api (+ worker)
	@for d in $(PKG_DIRS); do \
	  echo "Installing editable: $$d"; \
	  $(UV) pip install -e $$d --python $(API_DIR)/.venv/bin/python; \
	done
	@if [ -d "$(WORKER_DIR)" ]; then \
	  for d in $(PKG_DIRS); do \
	    $(UV) pip install -e $$d --python $(WORKER_DIR)/.venv/bin/python; \
	  done \
	fi

.PHONY: install-web
install-web: ## Install frontend deps (pnpm if available else npm)
	cd $(WEB_DIR) && $(NODE_PM) install

# --- dev runs (outside docker) ---
.PHONY: dev
dev: ## Run api + web dev servers (assumes stack is up for db/vector)
	@echo "Run in two terminals:"
	@echo "  make dev-api"
	@echo "  make dev-web"

.PHONY: dev-api
dev-api: ## Run FastAPI with reload (uv venv)
	cd $(API_DIR) && $(UV) run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

.PHONY: dev-web
dev-web: ## Run Next.js dev server
	cd $(WEB_DIR) && $(NODE_PM) run dev

.PHONY: dev-worker
dev-worker: ## Run worker locally (if present)
	cd $(WORKER_DIR) && $(UV) run python -m worker.main

# --- quality ---
.PHONY: fmt
fmt: fmt-py fmt-web ## Format all

.PHONY: fmt-py
fmt-py: ## Format python (ruff format)
	cd $(API_DIR) && $(UV) run ruff format .
	@for d in $(PKG_DIRS); do (cd $$d && $(UV) run ruff format .); done
	@if [ -d "$(WORKER_DIR)" ]; then (cd $(WORKER_DIR) && $(UV) run ruff format .); fi

.PHONY: fmt-web
fmt-web: ## Format web (prettier)
	cd $(WEB_DIR) && $(NODE_PM) run format

.PHONY: lint
lint: lint-py lint-web ## Lint all

.PHONY: lint-py
lint-py: ## Lint python (ruff)
	cd $(API_DIR) && $(UV) run ruff check .
	@for d in $(PKG_DIRS); do (cd $$d && $(UV) run ruff check .); done
	@if [ -d "$(WORKER_DIR)" ]; then (cd $(WORKER_DIR) && $(UV) run ruff check .); fi

.PHONY: lint-web
lint-web: ## Lint web (eslint)
	cd $(WEB_DIR) && $(NODE_PM) run lint

.PHONY: typecheck
typecheck: typecheck-web ## Typecheck (add mypy/pyright later if you want)

.PHONY: typecheck-web
typecheck-web: ## Typecheck TS
	cd $(WEB_DIR) && $(NODE_PM) run typecheck

.PHONY: test
test: test-py test-web ## Run all tests

.PHONY: test-py
test-py: ## Python tests
	cd $(API_DIR) && $(UV) run pytest
	@for d in $(PKG_DIRS); do (cd $$d && $(UV) run pytest || true); done
	@if [ -d "$(WORKER_DIR)" ]; then (cd $(WORKER_DIR) && $(UV) run pytest || true); fi

.PHONY: test-web
test-web: ## Web tests (if configured)
	cd $(WEB_DIR) && $(NODE_PM) run test

.PHONY: check
check: lint typecheck test ## CI-style checks

# --- database (api project owns alembic) ---
.PHONY: db-migrate
db-migrate: ## Alembic upgrade head
	cd $(API_DIR) && $(UV) run alembic upgrade head

.PHONY: db-revision
db-revision: ## Create alembic revision: make db-revision MSG="add activities"
	@test -n "$(MSG)" || (echo "MSG is required"; exit 1)
	cd $(API_DIR) && $(UV) run alembic revision --autogenerate -m "$(MSG)"

.PHONY: db-shell
db-shell: ## Open psql shell into postgres container
	$(COMPOSE) -f infra/compose.yaml exec -it postgres psql -U $$POSTGRES_USER -d $$POSTGRES_DB

# --- generation: OpenAPI + TS client ---
.PHONY: gen
gen: gen-openapi gen-ts-client ## Generate OpenAPI + TS client

.PHONY: gen-openapi
gen-openapi: ## Export OpenAPI spec from FastAPI to packages/shared/openapi
	cd $(API_DIR) && $(UV) run python -m app.core.export_openapi ../../packages/shared/openapi/skillbucket.openapi.json

.PHONY: gen-ts-client
gen-ts-client: ## Generate TS client/types from OpenAPI (requires package script)
	cd packages/shared/typescript && $(NODE_PM) run gen

# --- smoke / health ---
.PHONY: health
health:
	@echo "Checking MinIO..." \
	&& curl -fsS http://localhost:9000/minio/health/ready >/dev/null \
	&& echo "  ok"
	@echo "Checking Qdrant..." \
	&& curl -fsS http://localhost:6333/readyz >/dev/null \
	&& echo "  ok"
	@echo "Checking Postgres..." \
	&& docker compose -f infra/compose.yaml exec -T postgres pg_isready -U $${POSTGRES_USER:-skillbucket} -d $${POSTGRES_DB:-skillbucket} >/dev/null \
	&& echo "  ok"

.PHONY: smoke
smoke: up health ## Bring stack up + health check
	@echo "Smoke OK"
