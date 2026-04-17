#!/usr/bin/env bash
set -euo pipefail

readonly MESSAGE_UNSUPPORTED="Unsupported operating system for OpenCode bootstrap. Supported platforms are macOS and Linux."

printf '%s\n' "${MESSAGE_UNSUPPORTED}" >&2
exit 1
