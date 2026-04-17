SHELL := /usr/bin/env bash

BOOTSTRAP_DARWIN := ./scripts/bootstrap-macos.sh
BOOTSTRAP_LINUX := ./scripts/bootstrap-linux.sh
BOOTSTRAP_UNKNOWN := ./scripts/bootstrap-unsupported.sh

.PHONY: install check reinstall install-telegram install-service

install:
	@case "$$(uname -s)" in \
		Darwin) $(BOOTSTRAP_DARWIN) install ;; \
		Linux) $(BOOTSTRAP_LINUX) install ;; \
		*) $(BOOTSTRAP_UNKNOWN) install ;; \
	esac

check:
	@case "$$(uname -s)" in \
		Darwin) $(BOOTSTRAP_DARWIN) check ;; \
		Linux) $(BOOTSTRAP_LINUX) check ;; \
		*) $(BOOTSTRAP_UNKNOWN) check ;; \
	esac

reinstall:
	@case "$$(uname -s)" in \
		Darwin) $(BOOTSTRAP_DARWIN) reinstall ;; \
		Linux) $(BOOTSTRAP_LINUX) reinstall ;; \
		*) $(BOOTSTRAP_UNKNOWN) reinstall ;; \
	esac

install-telegram:
	@case "$$(uname -s)" in \
		Darwin) $(BOOTSTRAP_DARWIN) install-telegram ;; \
		Linux) $(BOOTSTRAP_LINUX) install-telegram ;; \
		*) $(BOOTSTRAP_UNKNOWN) install-telegram ;; \
	esac

install-service:
	@case "$$(uname -s)" in \
		Darwin) $(BOOTSTRAP_DARWIN) install-service ;; \
		Linux) $(BOOTSTRAP_LINUX) install-service ;; \
		*) $(BOOTSTRAP_UNKNOWN) install-service ;; \
	esac
