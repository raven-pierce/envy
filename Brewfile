# ============================================================================
# Homebrew Bundle
#
# Selectable groups (set by scripts/install.sh; default on if unset):
#   DOTFILES_BREW_CLI=1        core CLI, languages, fonts, taps they need
#   DOTFILES_BREW_APPS=1       GUI casks + Mac App Store
#   DOTFILES_BREW_WM=1         yabai / skhd / borders + related
#   DOTFILES_BREW_SKETCHYBAR=1 SketchyBar, lua, luarocks, audio helpers
# ============================================================================

cli  = ENV.fetch("DOTFILES_BREW_CLI",        "1") == "1"
apps = ENV.fetch("DOTFILES_BREW_APPS",       "1") == "1"
wm   = ENV.fetch("DOTFILES_BREW_WM",         "1") == "1"
sbar = ENV.fetch("DOTFILES_BREW_SKETCHYBAR", "1") == "1"

# ============================================================================
# Taps
# ============================================================================

tap "asmvik/formulae" if wm
tap "docker/tap" if cli || apps
tap "felixkratz/formulae" if sbar || wm
tap "jesseduffield/lazydocker" if cli
tap "jesseduffield/lazygit" if cli
tap "lerd-env/lerd" if cli
tap "stripe/stripe-cli" if cli

# ============================================================================
# Core System & CLI Tools
# ============================================================================

# Shell and Utilities
brew "bash" if cli
brew "gum" if cli
brew "vivid" if cli
brew "zsh" if cli
brew "zsh-autosuggestions" if cli
brew "zsh-completions" if cli
brew "zsh-syntax-highlighting" if cli

# GNU Core Utilities
brew "coreutils" if cli
brew "findutils" if cli
brew "gnu-sed" if cli
brew "grep" if cli
brew "less" if cli

# Modern CLI Replacements
brew "bat" if cli
brew "btop" if cli
brew "eza" if cli
brew "fastfetch" if cli
brew "fd" if cli
brew "fzf" if cli
brew "htop" if cli
brew "ripgrep" if cli
brew "yazi" if cli
brew "zoxide" if cli

# File and Data Tools
brew "jq" if cli
brew "stow" if cli
brew "tmux" if cli
brew "trash" if cli
brew "tree" if cli
brew "unzip" if cli
brew "yq" if cli
cask "rar" if cli

# Network Tools
brew "curl" if cli
brew "nmap" if cli
brew "wget" if cli

# Media & Audio Tools
brew "nowplaying-cli" if sbar
brew "switchaudio-osx" if sbar
cask "focusrite-control-2" if apps

# ============================================================================
# Version Control & Development Core
# ============================================================================

brew "gh" if cli
brew "git" if cli
brew "git-delta" if cli
brew "lazygit" if cli
brew "tuicr" if cli

# Security Tools
brew "gnupg" if cli
brew "openssh" if cli
cask "1password-cli" if cli

# ============================================================================
# Window Management & macOS Enhancements
# ============================================================================

brew "borders" if wm
brew "mas" if cli
brew "skhd" if wm
brew "sketchybar" if sbar
brew "yabai" if wm
cask "linearmouse" if wm
cask "logitech-g-hub" if apps

# ============================================================================
# Programming Languages & Runtimes
# ============================================================================

brew "lua" if sbar
brew "luarocks" if sbar
brew "python" if cli

# ============================================================================
# Development Tools & IDEs
# ============================================================================

# Editors
brew "neovim" if cli
cask "claude" if apps
cask "claude-code" if apps
cask "cursor" if apps
cask "jetbrains-toolbox" if apps
cask "visual-studio-code" if apps

# Development Services
brew "cloudflared" if cli
brew "lerd" if cli
brew "stripe" if cli
cask "bruno" if apps

# Git Clients
cask "gitkraken" if apps
cask "tower" if apps

# ============================================================================
# DevOps & Infrastructure
# ============================================================================

brew "lazydocker" if cli
cask "docker-desktop" if apps
cask "sbx" if apps

# ============================================================================
# Database Management
# ============================================================================

cask "redis-insight" if apps
cask "tableplus" if apps

# ============================================================================
# Applications
# ============================================================================

# Security & System
brew "mole" if cli
brew "pinentry-mac" if cli
cask "1password" if apps
cask "little-snitch" if apps
cask "mullvad-vpn" if apps
cask "raycast" if apps

# Terminals
cask "warp" if apps

# Browsers
cask "firefox" if apps

# Communication
cask "discord" if apps
cask "slack" if apps
cask "zoom" if apps

# Design & Media
cask "figma" if apps
cask "mactex-no-gui" if apps
cask "spotify" if apps

# Project Management
cask "linear" if apps

# ============================================================================
# Fonts
# ============================================================================

cask "font-jetbrains-mono" if cli
cask "font-jetbrains-mono-nerd-font" if cli
cask "font-sf-mono" if cli
cask "font-sf-pro" if cli
cask "sf-symbols" if cli

# ============================================================================
# Mac App Store
# ============================================================================

mas "1Password for Safari", id: 1569813296 if apps
mas "uBlock Origin Lite", id: 6745342698 if apps
mas "Xcode", id: 497799835 if apps
