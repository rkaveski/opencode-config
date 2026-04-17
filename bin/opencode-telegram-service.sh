#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly CONFIG_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly LOCAL_ENV_FILE="${OPENCODE_LOCAL_ENV_FILE:-${CONFIG_HOME}/opencode.local.env}"
readonly ENV_FILE="${OPENCODE_TELEGRAM_ENV_FILE:-${CONFIG_DIR}/telegram-bot.env}"
readonly APP_HOME="${OPENCODE_TELEGRAM_HOME:-${CONFIG_DIR}/telegram-bot-home}"
readonly SETTINGS_FILE="${OPENCODE_TELEGRAM_SETTINGS_FILE:-${APP_HOME}/settings.json}"
readonly OPENCODE_TELEGRAM_BIN="${OPENCODE_TELEGRAM_BIN:-$(command -v opencode-telegram || true)}"

export OPENCODE_TELEGRAM_HOME="${APP_HOME}"

if [[ -f "${LOCAL_ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${LOCAL_ENV_FILE}"
  set +a
fi

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  source "${ENV_FILE}"
  set +a
fi

: "${OPENCODE_API_URL:=http://127.0.0.1:4096}"

required_vars=(
  TELEGRAM_BOT_TOKEN
  TELEGRAM_ALLOWED_USER_ID
  OPENCODE_MODEL_PROVIDER
  OPENCODE_MODEL_ID
)

missing=()
for name in "${required_vars[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    missing+=("${name}")
  fi
done

if (( ${#missing[@]} > 0 )); then
  print -u2 "Missing required Telegram bot settings in ${ENV_FILE}: ${missing[*]}"
  print -u2 "Fill in telegram-bot.env, then bootstrap the launch agent again."
  exit 64
fi

if [[ -z "${OPENCODE_TELEGRAM_BIN}" ]]; then
  printf 'Unable to find `opencode-telegram` in PATH. Set OPENCODE_TELEGRAM_BIN if it is installed in a non-standard location.\n' >&2
  exit 64
fi

mkdir -p "${APP_HOME}"
cp "${ENV_FILE}" "${APP_HOME}/.env"
[[ -f "${SETTINGS_FILE}" ]] || printf '{}\n' > "${SETTINGS_FILE}"

exec "${OPENCODE_TELEGRAM_BIN}" start
