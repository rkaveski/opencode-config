#!/usr/bin/env bash
set -euo pipefail

readonly PLATFORM_SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly MACOS_SERVICE_LABEL_SERVER="ai.opencode.server"
readonly MACOS_SERVICE_LABEL_TELEGRAM="ai.opencode.telegram"
readonly MACOS_LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
readonly MACOS_LOG_DIR="${HOME}/Library/Logs/opencode"

# shellcheck source=./bootstrap-common.sh
source "${PLATFORM_SCRIPT_DIR}/bootstrap-common.sh"

render_launchd_template() {
  local template_file
  local target_file
  local service_label

  template_file="$1"
  target_file="$2"
  service_label="$3"

  mkdir -p "$(dirname -- "${target_file}")" "${MACOS_LOG_DIR}"

  sed \
    -e "s|__SERVICE_LABEL__|${service_label}|g" \
    -e "s|__INSTALL_DIR__|${OPENCODE_INSTALL_DIR}|g" \
    -e "s|__WORKING_DIRECTORY__|${OPENCODE_SERVER_WORKDIR:-${HOME}}|g" \
    -e "s|__LOG_DIR__|${MACOS_LOG_DIR}|g" \
    "${template_file}" > "${target_file}"
}

install_macos_server_service() {
  local template_file
  local target_file

  template_file="${REPO_ROOT}/templates/launchd/opencode-server.plist.template"
  target_file="${MACOS_LAUNCH_AGENTS_DIR}/${MACOS_SERVICE_LABEL_SERVER}.plist"
  render_launchd_template "${template_file}" "${target_file}" "${MACOS_SERVICE_LABEL_SERVER}"
  launchctl bootout "gui/$(id -u)/${MACOS_SERVICE_LABEL_SERVER}" >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$(id -u)" "${target_file}"
  launchctl kickstart -k "gui/$(id -u)/${MACOS_SERVICE_LABEL_SERVER}"
  log_info "Installed macOS server service ${MACOS_SERVICE_LABEL_SERVER}"
}

install_macos_telegram_service() {
  local template_file
  local target_file

  template_file="${REPO_ROOT}/templates/launchd/opencode-telegram.plist.template"
  target_file="${MACOS_LAUNCH_AGENTS_DIR}/${MACOS_SERVICE_LABEL_TELEGRAM}.plist"
  render_launchd_template "${template_file}" "${target_file}" "${MACOS_SERVICE_LABEL_TELEGRAM}"
  launchctl bootout "gui/$(id -u)/${MACOS_SERVICE_LABEL_TELEGRAM}" >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$(id -u)" "${target_file}"
  launchctl kickstart -k "gui/$(id -u)/${MACOS_SERVICE_LABEL_TELEGRAM}"
  log_info "Installed macOS Telegram service ${MACOS_SERVICE_LABEL_TELEGRAM}"
}

case "${BOOTSTRAP_ACTION}" in
  check)
    run_common_check
    ;;
  install)
    run_common_install
    ;;
  reinstall)
    run_common_install
    ;;
  install-service)
    run_common_install
    install_macos_server_service
    ;;
  install-telegram)
    run_common_install
    ensure_telegram_local_files
    require_telegram_env_values
    install_macos_telegram_service
    ;;
  *)
    fail "Unsupported bootstrap action: ${BOOTSTRAP_ACTION}"
    ;;
esac
