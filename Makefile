# Inspiration:
# - https://devhints.io/makefile
# - https://tech.davis-hansson.com/p/make/
# - https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

SHELL := bash

# Default - top level rule is what gets run when you run just `make` without specifying a goal/target.
.DEFAULT_GOAL := help

.DELETE_ON_ERROR:
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later.)
endif
.RECIPEPREFIX = >

image_repository ?= "jlucktay/TODO"

# Adjust the width of the first column by changing the '16' value in the printf pattern.
help:
> @grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
  | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'
.PHONY: help

all: test lint build ## Build and lint and test.
.PHONY: all

test: tmp/.tests-passed.sentinel ## Run tests.
.PHONY: test

lint: tmp/.linted.sentinel ## Lint all of the Go code. Will also test.
.PHONY: lint

build: out/image-id ## Build the Docker image. Will also lint and test.
.PHONY: build

clean: ## Clean up the temp and output directories. This will cause everything to get rebuilt.
> rm -rf tmp
> rm -rf out
.PHONY: clean

clean-docker: ## Clean up any built Docker images.
> docker images \
  --filter=reference=$(image_repository) \
  --no-trunc --quiet | sort -f | uniq | xargs -n 1 docker rmi --force
> rm -f out/image-id
.PHONY: clean-docker

# Tests - re-run if any Go files have changes since tmp/.tests-passed.sentinel last touched.
tmp/.tests-passed.sentinel: $(shell find . -type f -iname "*.go")
> mkdir -p $(@D)
> go test ./...
> touch $@

# Lint - re-run if the tests have been re-run (and so, by proxy, whenever the source files have changed).
tmp/.linted.sentinel: tmp/.tests-passed.sentinel
> mkdir -p $(@D)
> golangci-lint run
> go vet ./...
> touch $@

# Docker image - re-build if the lint output is re-run.
out/image-id: tmp/.linted.sentinel
> mkdir -p $(@D)
> image_id="$(image_repository):$$(uuidgen)"
> docker build --tag="$${image_id}" .
> echo "$${image_id}" > out/image-id
