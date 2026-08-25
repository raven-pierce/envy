#!/usr/bin/env bash
# Start window management services. Does not apply macos.sh defaults.

set -euo pipefail

scrDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=global_fn.sh
source "${scrDir}/global_fn.sh"

print_log -sec "install-services" -info "Starting" "Window management services"

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

start_brew_service "sketchybar"
start_brew_service "borders"

if pkg_installed "yabai"; then
    print_log -sec "install-services" -info "Service" "Starting yabai..."
    yabai --stop-service 2>/dev/null || true
    if yabai --start-service; then
        print_log -sec "install-services" -g "Started" "yabai"
    else
        print_log -sec "install-services" -warn "Failed" "Could not start yabai"
    fi
else
    print_log -sec "install-services" -y "Skip" "yabai not installed"
fi

if pkg_installed "skhd"; then
    print_log -sec "install-services" -info "Service" "Starting skhd..."
    skhd --stop-service 2>/dev/null || true
    if skhd --start-service; then
        print_log -sec "install-services" -g "Started" "skhd"
    else
        print_log -sec "install-services" -warn "Failed" "Could not start skhd"
    fi
else
    print_log -sec "install-services" -y "Skip" "skhd not installed"
fi

print_log -sec "install-services" -info "Security" "Checking System Integrity Protection..."
sip_status="$(csrutil status 2>/dev/null || true)"
if printf '%s' "${sip_status}" | grep -qi "enabled"; then
    print_log -sec "install-services" -warn "SIP" "SIP is enabled — some yabai features may be limited"
else
    print_log -sec "install-services" -g "SIP" "SIP appears disabled — full yabai feature set available"
fi

print_log -sec "install-services" -g "Complete" "Service setup completed"
print_log -sec "install-services" -info "Next" "Grant Accessibility permissions if prompted, then log out/in"
