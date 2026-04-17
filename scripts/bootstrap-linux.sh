#!/usr/bin/env bash
set -euo pipefail

readonly PLATFORM_SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly LINUX_SERVICE_LABEL_SERVER="ai.opencode.server"
readonly LINUX_SERVICE_LABEL_TELEGRAM="ai.opencode.telegram"

# shellcheck source=./bootstrap-common.sh
source "${PLATFORM_SCRIPT_DIR}/bootstrap-common.sh"
# shellcheck source=./check-prereqs-linux.sh
source "${PLATFORM_SCRIPT_DIR}/check-prereqs-linux.sh"

render_systemd_template() {
  local template_file
  local target_file

  template_file="$1"
  target_file="$2"

  mkdir -p "$(dirname -- "${target_file}")"

  sed \
    -e "s|__INSTALL_DIR__|${OPENCODE_INSTALL_DIR}|g" \
    -e "s|__WORKING_DIRECTORY__|${OPENCODE_SERVER_WORKDIR:-${HOME}}|g" \
    "${template_file}" > "${target_file}"
}

install_linux_server_service() {
  local target_dir
  local target_file
  local template_file

  require_systemd_user

  target_dir="${HOME}/.config/systemd/user"
  target_file="${target_dir}/${LINUX_SERVICE_LABEL_SERVER}.service"
  template_file="${REPO_ROOT}/templates/systemd/opencode-server.service.template"

  render_systemd_template "${template_file}" "${target_file}"
  systemctl --user daemon-reload
  systemctl --user enable --now "${LINUX_SERVICE_LABEL_SERVER}.service"
  log_info "Installed Linux server service ${LINUX_SERVICE_LABEL_SERVER}"
}

install_linux_telegram_service() {
  local target_dir
  local target_file
  local template_file

  require_systemd_user

  target_dir="${HOME}/.config/systemd/user"
  target_file="${target_dir}/${LINUX_SERVICE_LABEL_TELEGRAM}.service"
  template_file="${REPO_ROOT}/templates/systemd/opencode-telegram.service.template"

  render_systemd_template "${template_file}" "${target_file}"
  systemctl --user daemon-reload
  systemctl --user enable --now "${LINUX_SERVICE_LABEL_TELEGRAM}.service"
  log_info "Installed Linux Telegram service ${LINUX_SERVICE_LABEL_TELEGRAM}"
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
    install_linux_server_service
    ;;
  install-telegram)
    run_common_install
    ensure_telegram_local_files
    require_telegram_env_values
    install_linux_telegram_service
    ;;
  *)
    fail "Unsupported bootstrap action: ${BOOTSTRAP_ACTION}"
    ;;
esac
