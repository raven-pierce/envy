#!/usr/bin/env bash
# Start selected window-management / SketchyBar services. Scope is set by
# DOTFILES_START_WM / DOTFILES_START_SBAR (both default on when run directly);
# every service is also guarded by pkg_installed, so only installed tools start.

set -euo pipefail

scrDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=global_fn.sh
source "${scrDir}/global_fn.sh"
enable_error_trap

START_WM="${DOTFILES_START_WM:-1}"
START_SBAR="${DOTFILES_START_SBAR:-1}"

print_log -sec "install-services" -info "Starting" "Service setup (wm=${START_WM} sketchybar=${START_SBAR})"

start_brew_service() {
    local service=$1
    if ! pkg_installed "${service}"; then
        print_log -sec "install-services" -y "Skip" "${service} not installed"
        return 0
    fi

    print_log -sec "install-services" -info "Service" "Starting ${service}..."
    brew services stop "${service}" 2>/dev/null || true
    if brew services start "${service}"; then
        print_log -sec "install-services" -g "Started" "${service}"
    else
        print_log -sec "install-services" -warn "Failed" "Could not start ${service}"
    fi
}

start_own_service() {
    # For tools that manage their own launchd service (yabai, skhd).
    local tool=$1
    if ! pkg_installed "${tool}"; then
        print_log -sec "install-services" -y "Skip" "${tool} not installed"
        return 0
    fi

    print_log -sec "install-services" -info "Service" "Starting ${tool}..."
    "${tool}" --stop-service 2>/dev/null || true
    if "${tool}" --start-service; then
        print_log -sec "install-services" -g "Started" "${tool}"
    else
        print_log -sec "install-services" -warn "Failed" "Could not start ${tool}"
    fi
}

if [[ "${START_SBAR}" == "1" ]]; then
    start_brew_service "sketchybar"
fi

if [[ "${START_WM}" == "1" ]]; then
    start_brew_service "borders"
    start_own_service "yabai"
    start_own_service "skhd"

    print_log -sec "install-services" -info "Security" "Checking System Integrity Protection..."
    sip_status="$(csrutil status 2>/dev/null || true)"
    if printf '%s' "${sip_status}" | grep -qi "enabled"; then
        print_log -sec "install-services" -warn "SIP" "SIP is enabled — some yabai features may be limited"
    else
        print_log -sec "install-services" -g "SIP" "SIP appears disabled — full yabai feature set available"
    fi
fi

print_log -sec "install-services" -g "Complete" "Service setup completed"
if [[ "${START_WM}" == "1" ]]; then
    print_log -sec "install-services" -info "Next" "Grant Accessibility permissions if prompted, then log out/in"
fi
