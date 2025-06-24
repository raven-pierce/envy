#!/usr/bin/env bash
#|---/ /+-------------------------+---/ /|#
#|--/ /-| Pre-installation script |--/ /-|#
#|-/ /--| ENVY Project            |-/ /--|#
#|/ /---+-------------------------+/ /---|#

# Source global functions
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/global_fn.sh"

print_log -sec "pre-install" -info "Starting" "ENVY pre-installation setup"

# Check macOS compatibility
if ! check_macos_version; then
    print_log -sec "pre-install" -err "Failed" "macOS version check failed"
    exit 1
fi

# Install Xcode Command Line Tools
print_log -sec "pre-install" -info "Xcode Tools" "Checking Xcode Command Line Tools..."
if ! xcode_tools_installed; then
    print_log -sec "pre-install" -warn "Missing" "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    print_log -sec "pre-install" -y "Waiting" "Please complete the Xcode Command Line Tools installation"
    print_log -sec "pre-install" -info "Notice" "The installer window should have appeared"
    
    # Wait for installation to complete
    while ! xcode_tools_installed; do
        sleep 5
        print_log -sec "pre-install" -y "Waiting" "Still waiting for Xcode Command Line Tools..."
    done
    
    print_log -sec "pre-install" -g "Success" "Xcode Command Line Tools installed"
else
    print_log -sec "pre-install" -g "Found" "Xcode Command Line Tools already installed"
fi

# Install Homebrew
print_log -sec "pre-install" -info "Homebrew" "Checking Homebrew installation..."
if ! homebrew_installed; then
    print_log -sec "pre-install" -warn "Missing" "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    print_log -sec "pre-install" -g "Success" "Homebrew installed"
    print_log -sec "pre-install" -info "Notice" "Homebrew PATH will be configured during shell setup"
else
    print_log -sec "pre-install" -g "Found" "Homebrew already installed"
fi

# Disable Homebrew analytics
print_log -sec "pre-install" -info "Privacy" "Disabling Homebrew analytics..."
brew analytics off

# Update Homebrew
print_log -sec "pre-install" -info "Update" "Updating Homebrew..."
brew update

# Create necessary directories
print_log -sec "pre-install" -info "Directories" "Creating necessary directories..."
mkdir -p "${cacheDir}/logs"
mkdir -p "${configDir}"

print_log -sec "pre-install" -g "Complete" "Pre-installation setup completed successfully" 