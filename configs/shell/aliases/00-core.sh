#!/bin/zsh
# Core System Aliases

# ========================================
# Better Replacements for Common Commands
# ========================================
alias cat="bat"
alias top="btop"
alias find="fd"
alias grep="rg"
alias z="zoxide"

# ========================================
# File and Directory Operations
# ========================================
alias ls="eza --color=always --grid --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias ll="eza -la --icons --git"
alias la="eza -a"
alias lt="eza --tree --level=2 --long --icons --git --color=always"
alias cp="cp -iv"
alias mv="mv -iv"

# ========================================
# System & Navigation
# ========================================
alias x="exit"
alias ping="ping -c 5"

# ========================================
# Development & Tools
# ========================================
alias vimm="vim"
alias sv="fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim"
alias ya="yazi"
alias d="delta"
alias f="fastfetch"
alias py="python3"
