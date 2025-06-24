#!/usr/bin/env bash
#|---/ /+------------------------+---/ /|#
#|--/ /-| Package install script |--/ /-|#
#|-/ /--| ENVY Project           |-/ /--|#
#|/ /---+------------------------+/ /---|#

# Source global functions
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/global_fn.sh"

print_log -sec "install-pkg" -info "Starting" "Package installation via Homebrew Bundle"

# Check if Homebrew is available
if ! homebrew_installed; then
    print_log -sec "install-pkg" -err "Missing" "Homebrew not found! Run pre-install first."
    exit 1
fi

# Locate Brewfile
brewfile="${envyDir}/Brewfile"
if [[ ! -f "$brewfile" ]]; then
    print_log -sec "install-pkg" -err "Missing" "Brewfile not found at ${brewfile}"
    exit 1
fi

print_log -sec "install-pkg" -info "Brewfile" "Found Brewfile at ${brewfile}"

# Install packages from Brewfile using brew bundle
print_log -sec "install-pkg" -info "Installing" "Installing packages from Brewfile..."
print_log -sec "install-pkg" -y "Notice" "This may take a while depending on your internet connection"

# Use brew bundle to install everything from the Brewfile
if brew bundle install --file="$brewfile"; then
    print_log -sec "install-pkg" -g "Success" "All packages installed successfully from Brewfile"
else
    exit_code=$?
    print_log -sec "install-pkg" -warn "Partial" "Some packages may have failed to install (exit code: ${exit_code})"
    print_log -sec "install-pkg" -info "Retry" "You can run 'brew bundle install --file=${brewfile}' manually to retry"
fi

# Quick verification that critical packages are available
print_log -sec "install-pkg" -info "Verification" "Verifying critical packages are available..."

critical_commands=(
    "git"
    "nvim"
    "yabai"
    "skhd"
    "sketchybar"
    "tmux"
    "zsh"
)

missing_commands=()

for cmd in "${critical_commands[@]}"; do
    if command_exists "$cmd"; then
        print_log -sec "install-pkg" -g "✓" "${cmd} available"
    else
        print_log -sec "install-pkg" -r "✗" "${cmd} not found in PATH"
        missing_commands+=("$cmd")
    fi
done

if [[ ${#missing_commands[@]} -eq 0 ]]; then
    print_log -sec "install-pkg" -g "Complete" "All critical packages are available"
else
    print_log -sec "install-pkg" -warn "Missing" "Some critical packages are not in PATH:"
    for cmd in "${missing_commands[@]}"; do
        print_log -sec "install-pkg" -r "Missing" "$cmd"
    done
    print_log -sec "install-pkg" -info "Note" "They may have been installed but require a shell restart"
fi

print_log -sec "install-pkg" -g "Complete" "Package installation completed" 