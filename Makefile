# Makefile
# uv + pytest + black + pre-commit with dependency groups: dev, test (+ core)
SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

UV            ?= uv
PYTHON        ?= python3
PRECOMMIT     ?= pre-commit

PYTEST_ARGS   ?=
SRC           ?= .
BLACK_LINE    ?= 88

UVRUN := $(UV) run

.PHONY: help
help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"; printf "\nTargets:\n"} /^[a-zA-Z0-9_\-]+:.*##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf "\nCommon flows:\n"
	@printf "  make setup        # core+dev+test + hooks\n"
	@printf "  make test         # run pytest\n"
	@printf "  make fmt          # black format\n"
	@printf "  make lint         # pre-commit on all files\n"
	@printf "  make ci           # fmt-check + lint + test\n\n"

.PHONY: check-tools
check-tools: ## Verify required tools exist
	@command -v $(UV) >/dev/null 2>&1 || (echo "ERROR: '$(UV)' not found. Install uv first."; exit 1)

.PHONY: venv
venv: check-tools ## Create/ensure venv (usually .venv)
	@$(UV) venv >/dev/null
	@echo "Virtual env ready."

# --- Dependency installs (uv groups) ---
.PHONY: sync-core
sync-core: check-tools venv ## Install only core dependencies (from lockfile)
	@$(UV) sync

.PHONY: sync-dev
sync-dev: check-tools venv ## Install core + dev group
	@$(UV) sync --group dev

.PHONY: sync-test
sync-test: check-tools venv ## Install core + test group
	@$(UV) sync --group test

.PHONY: sync-all
sync-all: check-tools venv ## Install core + dev + test groups
	@$(UV) sync --group dev --group test

.PHONY: setup
setup: sync-all hooks ## One-shot dev setup: deps + hooks

.PHONY: hooks
hooks: check-tools venv ## Install pre-commit git hooks (requires .pre-commit-config.yaml)
	@$(UVRUN) $(PRECOMMIT) install
	@$(UVRUN) $(PRECOMMIT) install --hook-type pre-push || true
	@echo "pre-commit hooks installed."

.PHONY: update
update: check-tools venv ## Upgrade deps + resync (updates lockfile)
	@$(UV) lock --upgrade
	@$(UV) sync --group dev --group test

# --- Formatting / Linting ---
.PHONY: fmt
fmt: check-tools venv ## Auto-format with Black
	@$(UVRUN) black --line-length $(BLACK_LINE) $(SRC)

.PHONY: fmt-check
fmt-check: check-tools venv ## Check formatting (no changes)
	@$(UVRUN) black --line-length $(BLACK_LINE) --check --diff $(SRC)

.PHONY: lint
lint: check-tools venv ## Run pre-commit on all files
	@$(UVRUN) $(PRECOMMIT) run --all-files

# --- Testing ---
.PHONY: test
test: check-tools venv ## Run pytest
	@$(UVRUN) pytest $(PYTEST_ARGS)

.PHONY: test-cov
test-cov: check-tools venv ## Run pytest with coverage (requires pytest-cov)
	@$(UVRUN) pytest --cov --cov-report=term-missing $(PYTEST_ARGS)

# --- CI meta-target ---
.PHONY: ci
ci: fmt-check lint test ## Typical local CI gate

# --- Clean ---
.PHONY: clean
clean: ## Remove caches and build artifacts (keeps .venv)
	@rm -rf .pytest_cache .mypy_cache .ruff_cache coverage.xml .coverage htmlcov dist build *.egg-info
	@find . -type d -name "__pycache__" -print0 | xargs -0 rm -rf || true

.PHONY: clobber
clobber: clean ## Remove everything including venv
	@rm -rf .venv

# --- Convenience ---
.PHONY: run
run: check-tools venv ## Run a module: make run M=your.module ARGS="..."
	@[ -n "$(M)" ] || (echo 'Usage: make run M=your.module ARGS="..."'; exit 2)
	@$(UVRUN) $(PYTHON) -m $(M) $(ARGS)
