#!/usr/bin/env bash
#|---/ /+------------------------+---/ /|#
#|--/ /-| Services install script |--/ /-|#
#|-/ /--| ENVY Project           |-/ /--|#
#|/ /---+------------------------+/ /---|#

# Source global functions
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/global_fn.sh"

print_log -sec "install-services" -info "Starting" "Service installation and configuration"

# Configure macOS system preferences using the macos.sh script
print_log -sec "install-services" -info "macOS" "Configuring macOS system preferences..."
if [[ -f "${scrDir}/macos.sh" ]]; then
    if bash "${scrDir}/macos.sh"; then
        print_log -sec "install-services" -g "Success" "macOS preferences configured"
    else
        print_log -sec "install-services" -warn "Failed" "Failed to configure macOS preferences"
    fi
else
    print_log -sec "install-services" -warn "Missing" "macos.sh script not found, skipping macOS configuration"
fi

# Start services
print_log -sec "install-services" -info "Services" "Starting window management services..."

# Homebrew services (excluding yabai and skhd which use their own startup methods)
brew_services=(
    "sketchybar"
    "borders"
)

for service in "${brew_services[@]}"; do
    if pkg_installed "$service"; then
        print_log -sec "install-services" -info "Service" "Starting ${service}..."
        
        # Stop service if already running
        brew services stop "$service" 2>/dev/null || true
        
        # Start service
        if brew services start "$service"; then
            print_log -sec "install-services" -g "Started" "${service} service started"
        else
            print_log -sec "install-services" -warn "Failed" "Could not start ${service} service"
        fi
    else
        print_log -sec "install-services" -y "Skip" "${service} not installed"
    fi
done

# Start yabai using its own startup method
if pkg_installed "yabai"; then
    print_log -sec "install-services" -info "Service" "Starting yabai..."
    
    # Stop yabai if already running
    yabai --stop-service 2>/dev/null || true
    
    # Start yabai service
    if yabai --start-service; then
        print_log -sec "install-services" -g "Started" "yabai service started"
    else
        print_log -sec "install-services" -warn "Failed" "Could not start yabai service"
    fi
else
    print_log -sec "install-services" -y "Skip" "yabai not installed"
fi

# Start skhd using its own startup method
if pkg_installed "skhd"; then
    print_log -sec "install-services" -info "Service" "Starting skhd..."
    
    # Stop skhd if already running
    skhd --stop-service 2>/dev/null || true
    
    # Start skhd service
    if skhd --start-service; then
        print_log -sec "install-services" -g "Started" "skhd service started"
    else
        print_log -sec "install-services" -warn "Failed" "Could not start skhd service"
    fi
else
    print_log -sec "install-services" -y "Skip" "skhd not installed"
fi

# Login services already configured above
print_log -sec "install-services" -info "Login Items" "Window management services configured for auto-start"

# Check SIP status for yabai
print_log -sec "install-services" -info "Security" "Checking System Integrity Protection status..."
sip_status=$(csrutil status)
if echo "$sip_status" | grep -q "enabled"; then
    print_log -sec "install-services" -warn "SIP" "System Integrity Protection is enabled"
    print_log -sec "install-services" -info "Notice" "Some yabai features may be limited"
    print_log -sec "install-services" -info "Optional" "Disable SIP for full yabai functionality:"
    print_log -sec "install-services" -info "Steps" "1. Boot into Recovery Mode (Cmd+R)"
    print_log -sec "install-services" -info "Steps" "2. Open Terminal"
    print_log -sec "install-services" -info "Steps" "3. Run: csrutil disable"
    print_log -sec "install-services" -info "Steps" "4. Reboot normally"
else
    print_log -sec "install-services" -g "SIP" "System Integrity Protection is disabled"
    print_log -sec "install-services" -g "Full" "All yabai features available"
fi

# Apply settings by restarting affected processes
print_log -sec "install-services" -info "Apply" "Applying changes by restarting system processes..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

print_log -sec "install-services" -g "Complete" "Service installation and configuration completed"
print_log -sec "install-services" -info "Next Steps" "Log out and log back in to apply all changes" 