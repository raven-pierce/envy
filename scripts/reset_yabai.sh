#!/usr/bin/env bash
# Reset yabai scripting addition and service.

set -euo pipefail

scrDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=global_fn.sh
source "${scrDir}/global_fn.sh"

print_log -sec "reset-yabai" -info "Starting" "Resetting yabai scripting addition and service"

if ! command_exists yabai; then
    print_log -sec "reset-yabai" -err "Missing" "yabai not found in PATH"
    exit 1
fi

YABAI_BIN="$(command -v yabai)"
YABAI_HASH="$(shasum -a 256 "${YABAI_BIN}" | cut -d " " -f 1)"
SUDOERS_FILE="/private/etc/sudoers.d/yabai"

print_log -sec "reset-yabai" -info "Binary" "${YABAI_BIN}"
print_log -sec "reset-yabai" -info "Hash" "${YABAI_HASH}"

# Keep sudo alive for the rest of the script
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true' EXIT

print_log -sec "reset-yabai" -info "Service" "Stopping and uninstalling yabai service..."
yabai --stop-service 2>/dev/null || true
yabai --uninstall-service 2>/dev/null || true

print_log -sec "reset-yabai" -info "SA" "Uninstalling scripting addition..."
if ! sudo yabai --uninstall-sa; then
    print_log -sec "reset-yabai" -err "SA" "Failed to uninstall the scripting addition — aborting to avoid a half-configured state"
    exit 1
fi

print_log -sec "reset-yabai" -info "Sudoers" "Rewriting ${SUDOERS_FILE}..."
sudo rm -f "${SUDOERS_FILE}"
echo "$(whoami) ALL=(root) NOPASSWD: sha256:${YABAI_HASH} ${YABAI_BIN} --load-sa" | sudo tee "${SUDOERS_FILE}" >/dev/null
sudo chmod 0440 "${SUDOERS_FILE}"

print_log -sec "reset-yabai" -info "SA" "Loading scripting addition..."
if ! sudo yabai --load-sa; then
    print_log -sec "reset-yabai" -err "SA" "Failed to load the scripting addition — check SIP and the sudoers entry"
    exit 1
fi

print_log -sec "reset-yabai" -info "Service" "Installing and starting yabai service..."
yabai --install-service
yabai --start-service

print_log -sec "reset-yabai" -g "Complete" "yabai scripting addition and service reset"
