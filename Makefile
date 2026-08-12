SHELL := /bin/bash
SCRIPTS := $(wildcard scripts/*.sh)
LIBS := $(wildcard lib/*.sh)
TESTS := $(wildcard tests/*.bash) tests/run.sh tests/stub/systemctl

.PHONY: help lint test check

help:
	@echo "make lint   - run shellcheck over all shell sources"
	@echo "make test   - run the test suite"
	@echo "make check  - lint + test"

lint:
	shellcheck -x $(SCRIPTS) $(LIBS) $(TESTS)

test:
	@bash tests/run.sh

check: lint test
