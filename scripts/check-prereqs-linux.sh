#!/usr/bin/env bash

require_systemd_user() {
  if ! command_exists systemctl; then
    fail "systemctl is required for Linux service installation."
  fi

  if ! systemctl --user show-environment >/dev/null 2>&1; then
    fail "systemd --user is not available in this session. Base install still works, but service installation does not."
  fi
}
