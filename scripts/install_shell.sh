#!/usr/bin/env bash
#|---/ /+----------------------+---/ /|#
#|--/ /-| Shell install script |--/ /-|#
#|-/ /--| ENVY Project         |-/ /--|#
#|/ /---+----------------------+/ /---|#

# Source global functions
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/global_fn.sh"

print_log -sec "install-shell" -info "Starting" "Shell environment installation"

# Install Oh My Zsh
print_log -sec "install-shell" -info "Oh My Zsh" "Installing Oh My Zsh framework..."
install_oh_my_zsh

# Install Powerlevel10k theme
print_log -sec "install-shell" -info "Powerlevel10k" "Installing Powerlevel10k theme..."
install_powerlevel10k

# Install Node Version Manager
print_log -sec "install-shell" -info "NVM" "Installing Node Version Manager..."
install_nvm

# Install useful Oh My Zsh plugins that aren't available via Homebrew
print_log -sec "install-shell" -info "Plugins" "Installing additional Oh My Zsh plugins..."

# Plugin directory
plugin_dir="${HOME}/.oh-my-zsh/custom/plugins"

# fzf-zsh-plugin (not available via Homebrew)
if [[ ! -d "${plugin_dir}/fzf-zsh-plugin" ]]; then
    print_log -sec "install-shell" -info "Plugin" "Installing fzf-zsh-plugin..."
    git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git "${plugin_dir}/fzf-zsh-plugin"
    print_log -sec "install-shell" -g "Success" "fzf-zsh-plugin installed"
else
    print_log -sec "install-shell" -y "Skip" "fzf-zsh-plugin already installed"
fi

# Set zsh as default shell if it isn't already
current_shell=$(echo $SHELL)
if [[ "$current_shell" != *"zsh" ]]; then
    print_log -sec "install-shell" -info "Default Shell" "Setting zsh as default shell..."
    
    # Get zsh path
    zsh_path=$(which zsh)
    
    # Add zsh to allowed shells if not already there
    if ! grep -q "$zsh_path" /etc/shells; then
        print_log -sec "install-shell" -warn "Permission" "Adding zsh to /etc/shells (requires sudo)..."
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi
    
    # Change default shell
    print_log -sec "install-shell" -warn "Permission" "Changing default shell (requires password)..."
    chsh -s "$zsh_path"
    print_log -sec "install-shell" -g "Success" "Default shell set to zsh"
else
    print_log -sec "install-shell" -g "Current" "zsh is already the default shell"
fi

print_log -sec "install-shell" -g "Complete" "Shell environment installation completed"
print_log -sec "install-shell" -info "Next Steps" "Shell configuration will be applied during config restoration"
print_log -sec "install-shell" -info "P10k Setup" "Run 'p10k configure' after config restoration to customize your prompt" 