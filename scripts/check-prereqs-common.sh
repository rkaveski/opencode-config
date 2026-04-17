#!/usr/bin/env bash

readonly EXIT_USAGE=64

log_info() {
  printf '[opencode] %s\n' "$*"
}

log_warn() {
  printf '[opencode] warning: %s\n' "$*" >&2
}

log_error() {
  printf '[opencode] error: %s\n' "$*" >&2
}

fail() {
  log_error "$*"
  exit "${EXIT_USAGE}"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_command() {
  local command_name
  command_name="$1"

  if ! command_exists "${command_name}"; then
    fail "Missing required command: ${command_name}"
  fi
}

bool_is_true() {
  local value
  value="${1:-false}"

  case "${value}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

require_file() {
  local file_path
  file_path="$1"

  if [[ ! -f "${file_path}" ]]; then
    fail "Missing required file: ${file_path}"
  fi
}
