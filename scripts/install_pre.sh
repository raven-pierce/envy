#!/usr/bin/env bash
# Prerequisites: Xcode CLT and Homebrew.

set -euo pipefail

scrDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=global_fn.sh
source "${scrDir}/global_fn.sh"
enable_error_trap

print_log -sec "pre-install" -info "Starting" "Pre-installation setup"

if ! check_macos_version; then
    print_log -sec "pre-install" -err "Failed" "macOS version check failed"
    exit 1
fi

print_log -sec "pre-install" -info "Xcode Tools" "Checking Xcode Command Line Tools..."
if ! xcode_tools_installed; then
    print_log -sec "pre-install" -warn "Missing" "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_log -sec "pre-install" -y "Waiting" "Complete the installer dialog, then this script will continue"

    attempt=0
    while ! xcode_tools_installed; do
        if ((attempt >= 120)); then
            print_log -sec "pre-install" -err "Timeout" "Xcode CLT not detected after 600s — finish the installer dialog, then re-run this script"
            exit 1
        fi
        sleep 5
        ((attempt++)) || true
        print_log -sec "pre-install" -y "Waiting" "Still waiting for Xcode Command Line Tools..."
    done
    print_log -sec "pre-install" -g "Success" "Xcode Command Line Tools installed"
else
    print_log -sec "pre-install" -g "Found" "Xcode Command Line Tools already installed"
fi

print_log -sec "pre-install" -info "Homebrew" "Checking Homebrew..."
if ! homebrew_installed; then
    print_log -sec "pre-install" -warn "Missing" "Installing Homebrew..."
    # Attach the real terminal so Homebrew runs interactively — it can prompt
    # for the sudo password and the RETURN-to-continue confirm. Piped in via
    # `curl | bash`, our stdin is the (closed) pipe, which makes Homebrew flip
    # to NONINTERACTIVE: it never prompts and then fails needing passwordless
    # sudo. With no terminal at all, ask for NONINTERACTIVE explicitly.
    if is_tty; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
    else
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Put brew on PATH for the rest of this session (Apple Silicon + Intel).
    ensure_brew_on_path
    print_log -sec "pre-install" -g "Success" "Homebrew installed"
else
    print_log -sec "pre-install" -g "Found" "Homebrew already installed"
fi

if ! command_exists gum; then
    print_log -sec "pre-install" -info "gum" "Installing gum (installer UI)..."
    with_retry 3 brew install gum
fi

print_log -sec "pre-install" -info "Privacy" "Disabling Homebrew analytics..."
brew analytics off

print_log -sec "pre-install" -info "Update" "Updating Homebrew..."
with_retry 3 run_spin "Updating Homebrew" brew update

mkdir -p "${cacheDir}/logs"

print_log -sec "pre-install" -g "Complete" "Pre-installation setup completed"
