#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
readonly DEFAULT_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
readonly DEFAULT_INSTALL_DIR="${DEFAULT_CONFIG_HOME}/opencode"
readonly DEFAULT_LOCAL_ENV_FILE="${DEFAULT_CONFIG_HOME}/opencode.local.env"
readonly DEFAULT_TELEGRAM_ENV_FILE="${DEFAULT_INSTALL_DIR}/telegram-bot.env"
readonly DEFAULT_TELEGRAM_SETTINGS_FILE="${DEFAULT_INSTALL_DIR}/telegram-bot-home/settings.json"
readonly LOCAL_ENV_TEMPLATE="${REPO_ROOT}/templates/opencode.local.env.example"
readonly TELEGRAM_ENV_TEMPLATE="${REPO_ROOT}/templates/telegram-bot.env.example"
readonly TELEGRAM_SETTINGS_TEMPLATE="${REPO_ROOT}/templates/telegram-settings.json.example"
readonly CONFIG_RENDERER="${REPO_ROOT}/scripts/render-config.mjs"

# shellcheck source=./check-prereqs-common.sh
source "${SCRIPT_DIR}/check-prereqs-common.sh"

BOOTSTRAP_ACTION="${1:-install}"
FORCE_REINSTALL=false

initialize_bootstrap_environment() {
  mkdir -p "${DEFAULT_CONFIG_HOME}"

  if [[ ! -f "${DEFAULT_LOCAL_ENV_FILE}" ]]; then
    cp "${LOCAL_ENV_TEMPLATE}" "${DEFAULT_LOCAL_ENV_FILE}"
    log_info "Created local override file at ${DEFAULT_LOCAL_ENV_FILE}"
  fi

  set -a
  # shellcheck disable=SC1090
  source "${DEFAULT_LOCAL_ENV_FILE}"
  set +a

  export OPENCODE_CONFIG_HOME="${XDG_CONFIG_HOME:-${DEFAULT_CONFIG_HOME}}"
  export OPENCODE_INSTALL_DIR="${OPENCODE_INSTALL_DIR:-${DEFAULT_INSTALL_DIR}}"
  export OPENCODE_LOCAL_ENV_FILE="${DEFAULT_LOCAL_ENV_FILE}"
  export OPENCODE_TELEGRAM_ENV_FILE="${OPENCODE_TELEGRAM_ENV_FILE:-${DEFAULT_TELEGRAM_ENV_FILE}}"
  export OPENCODE_TELEGRAM_SETTINGS_FILE="${OPENCODE_TELEGRAM_SETTINGS_FILE:-${DEFAULT_TELEGRAM_SETTINGS_FILE}}"
}

run_common_prereq_checks() {
  require_command bash
  require_command node
  require_command opencode
}

copy_directory_contents() {
  local source_dir
  local target_dir

  source_dir="$1"
  target_dir="$2"

  mkdir -p "${target_dir}"

  if [[ "$(cd -- "${source_dir}" && pwd -P)" == "$(cd -- "${target_dir}" && pwd -P)" ]]; then
    return 0
  fi

  cp -R "${source_dir}/." "${target_dir}/"
}

copy_file_if_different_root() {
  local source_file
  local target_file
  local source_parent
  local target_parent

  source_file="$1"
  target_file="$2"
  source_parent="$(cd -- "$(dirname -- "${source_file}")" && pwd -P)"
  target_parent="$(mkdir -p "$(dirname -- "${target_file}")" && cd -- "$(dirname -- "${target_file}")" && pwd -P)"

  if [[ "${source_parent}" == "${target_parent}" && "$(basename -- "${source_file}")" == "$(basename -- "${target_file}")" ]]; then
    return 0
  fi

  cp "${source_file}" "${target_file}"
}

install_base_assets() {
  local asset_dir
  local asset_dirs

  asset_dirs=(
    agents
    bin
    commands
    instructions
    prompts
    skills
  )

  mkdir -p "${OPENCODE_INSTALL_DIR}"

  for asset_dir in "${asset_dirs[@]}"; do
    copy_directory_contents "${REPO_ROOT}/${asset_dir}" "${OPENCODE_INSTALL_DIR}/${asset_dir}"
  done

  copy_file_if_different_root "${TELEGRAM_ENV_TEMPLATE}" "${OPENCODE_INSTALL_DIR}/telegram-bot.env.example"
}

render_runtime_config() {
  node "${CONFIG_RENDERER}" "${OPENCODE_INSTALL_DIR}/opencode.json"
}

ensure_telegram_local_files() {
  mkdir -p "$(dirname -- "${OPENCODE_TELEGRAM_ENV_FILE}")" "$(dirname -- "${OPENCODE_TELEGRAM_SETTINGS_FILE}")"

  if [[ ! -f "${OPENCODE_TELEGRAM_ENV_FILE}" ]]; then
    cp "${TELEGRAM_ENV_TEMPLATE}" "${OPENCODE_TELEGRAM_ENV_FILE}"
    log_info "Created Telegram env file at ${OPENCODE_TELEGRAM_ENV_FILE}"
  fi

  if [[ ! -f "${OPENCODE_TELEGRAM_SETTINGS_FILE}" ]]; then
    cp "${TELEGRAM_SETTINGS_TEMPLATE}" "${OPENCODE_TELEGRAM_SETTINGS_FILE}"
    log_info "Created Telegram settings file at ${OPENCODE_TELEGRAM_SETTINGS_FILE}"
  fi
}

require_telegram_env_values() {
  local required_names
  local missing_names
  local name

  required_names=(
    TELEGRAM_BOT_TOKEN
    TELEGRAM_ALLOWED_USER_ID
    OPENCODE_MODEL_PROVIDER
    OPENCODE_MODEL_ID
  )
  missing_names=()

  if [[ -f "${OPENCODE_TELEGRAM_ENV_FILE}" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${OPENCODE_TELEGRAM_ENV_FILE}"
    set +a
  fi

  for name in "${required_names[@]}"; do
    if [[ -z "${!name:-}" ]]; then
      missing_names+=("${name}")
    fi
  done

  if (( ${#missing_names[@]} > 0 )); then
    fail "Telegram support requires values in ${OPENCODE_TELEGRAM_ENV_FILE}: ${missing_names[*]}"
  fi
}

run_common_install() {
  initialize_bootstrap_environment
  run_common_prereq_checks
  install_base_assets
  render_runtime_config
}

run_common_check() {
  initialize_bootstrap_environment
  run_common_prereq_checks
  log_info "Base install prerequisites look good."
}
