#!/usr/bin/env bash
set -euo pipefail

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly LOCAL_ENV_FILE="${OPENCODE_LOCAL_ENV_FILE:-${CONFIG_HOME}/opencode.local.env}"
readonly TRANSPORT_FLAG="--transport"
readonly STDIO_VALUE="stdio"
readonly API_KEY_FLAG="--api-key"

if [[ -f "${LOCAL_ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${LOCAL_ENV_FILE}"
  set +a
fi

readonly NODE_BIN="${OPENCODE_NODE_BIN:-$(command -v node || true)}"
readonly CONTEXT7_ENTRY="${CONTEXT7_MCP_ENTRY:-}"

if [[ -z "${NODE_BIN}" ]]; then
  printf 'Unable to find `node` in PATH. Set OPENCODE_NODE_BIN if it is installed in a non-standard location.\n' >&2
  exit 64
fi

if [[ -z "${CONTEXT7_ENTRY}" ]]; then
  printf 'Set CONTEXT7_MCP_ENTRY in %s before enabling Context7.\n' "${LOCAL_ENV_FILE}" >&2
  exit 64
fi

if [[ -z "${CONTEXT7_API_KEY:-}" ]]; then
  printf 'Set CONTEXT7_API_KEY in %s before enabling Context7.\n' "${LOCAL_ENV_FILE}" >&2
  exit 64
fi

exec "${NODE_BIN}" "${CONTEXT7_ENTRY}" "${TRANSPORT_FLAG}" "${STDIO_VALUE}" "${API_KEY_FLAG}" "${CONTEXT7_API_KEY}"
