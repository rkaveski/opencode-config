#!/usr/bin/env bash
set -euo pipefail

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly LOCAL_ENV_FILE="${OPENCODE_LOCAL_ENV_FILE:-${CONFIG_HOME}/opencode.local.env}"
readonly MODULE_SWITCH="-m"

if [[ -f "${LOCAL_ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${LOCAL_ENV_FILE}"
  set +a
fi

readonly PYTHON_BIN="${OPENCODE_WORKSPACE_DOCS_PYTHON:-${WORKSPACE_DOCS_PYTHON:-$(command -v python3 || true)}}"
readonly WORKSPACE_DOCS_MODULE_NAME="${WORKSPACE_DOCS_MODULE:-workspace_docs_mcp.server}"

if [[ -z "${PYTHON_BIN}" ]]; then
  printf 'Unable to find `python3` in PATH. Set OPENCODE_WORKSPACE_DOCS_PYTHON if it is installed in a non-standard location.\n' >&2
  exit 64
fi

exec "${PYTHON_BIN}" "${MODULE_SWITCH}" "${WORKSPACE_DOCS_MODULE_NAME}"
