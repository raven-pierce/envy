#!/usr/bin/env bash
# Shell environment: Oh My Zsh, Powerlevel10k, NVM, plugins.

set -euo pipefail

scrDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=global_fn.sh
source "${scrDir}/global_fn.sh"
enable_error_trap

print_log -sec "install-shell" -info "Starting" "Shell environment installation"

install_oh_my_zsh
install_powerlevel10k
install_nvm

plugin_dir="${HOME}/.oh-my-zsh/custom/plugins"
mkdir -p "${plugin_dir}"

if [[ ! -d "${plugin_dir}/fzf-zsh-plugin" ]]; then
    print_log -sec "install-shell" -info "Plugin" "Installing fzf-zsh-plugin..."
    with_retry 3 run_spin "Cloning fzf-zsh-plugin" \
        git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git "${plugin_dir}/fzf-zsh-plugin"
    print_log -sec "install-shell" -g "Success" "fzf-zsh-plugin installed"
else
    print_log -sec "install-shell" -y "Skip" "fzf-zsh-plugin already installed"
fi

current_shell="${SHELL:-}"
if [[ "${current_shell}" != *zsh* ]]; then
    print_log -sec "install-shell" -info "Default Shell" "Setting zsh as default shell..."
    zsh_path="$(command -v zsh)"

    if ! grep -Fxq "${zsh_path}" /etc/shells 2>/dev/null; then
        print_log -sec "install-shell" -warn "Permission" "Adding zsh to /etc/shells (sudo)..."
        echo "${zsh_path}" | sudo tee -a /etc/shells >/dev/null
    fi

    print_log -sec "install-shell" -warn "Permission" "Changing default shell (may prompt for password)..."
    chsh -s "${zsh_path}"
    print_log -sec "install-shell" -g "Success" "Default shell set to zsh"
else
    print_log -sec "install-shell" -g "Current" "zsh is already the default shell"
fi

print_log -sec "install-shell" -g "Complete" "Shell environment installation completed"
print_log -sec "install-shell" -info "P10k" "After configs are linked, run: p10k configure"
