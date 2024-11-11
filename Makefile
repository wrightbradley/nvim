# Variables
PROJECT_NAME = nvim
PYTHON = python3
ROOT_DIR := $(CURDIR)
SHELL := /bin/bash

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all
all: help

## Init:
.PHONY: init
init: direnv vale pre-commit-init ## initialize environment

.PHONY: direnv
direnv: ## setup direnv for env
	cp .envrc.sample .envrc && direnv allow .

.PHONY: vale
vale: ## setup vale
	vale sync --config .vale.ini

.PHONY: pre-commit-init
pre-commit-init: ## install pre-commit
	pre-commit install

## Lint:
.PHONY: lint
lint: pre-commit ## Run linters

.PHONY: pre-commit
pre-commit: ## Run pre-commit
	pre-commit run -a

## Docs:
.PHONY: gen-docs
gen-docs: ## Run scripts/gen-nvim-plugin-catalog.py
	uv run scripts/gen-nvim-plugin-catalog.py

## Help:
.PHONY: help
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)
