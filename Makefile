SHELL := /bin/bash
SCRIPTS := $(wildcard scripts/*.sh)
LIBS := $(wildcard lib/*.sh)

.PHONY: help lint test check

help:
	@echo "make lint   - run shellcheck over all shell sources"
	@echo "make test   - run the test suite"
	@echo "make check  - lint + test"

lint:
	shellcheck -x $(SCRIPTS) $(LIBS)

test:
	@echo "no tests yet - added on Day 09"

check: lint test
