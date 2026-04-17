#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly CONFIG_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly LOCAL_ENV_FILE="${OPENCODE_LOCAL_ENV_FILE:-${CONFIG_HOME}/opencode.local.env}"

if [[ -f "${LOCAL_ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${LOCAL_ENV_FILE}"
  set +a
fi

readonly OPENCODE_BIN="${OPENCODE_BIN:-$(command -v opencode || true)}"
readonly SERVER_WORKDIR="${OPENCODE_SERVER_WORKDIR:-${HOME}}"

if [[ -z "${OPENCODE_BIN}" ]]; then
  printf 'Unable to find `opencode` in PATH. Set OPENCODE_BIN if it is installed in a non-standard location.\n' >&2
  exit 64
fi

cd "${SERVER_WORKDIR}"

exec "${OPENCODE_BIN}" serve \
  --hostname "${OPENCODE_SERVER_HOSTNAME:-127.0.0.1}" \
  --port "${OPENCODE_SERVER_PORT:-4096}"
