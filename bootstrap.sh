#!/usr/bin/env bash
# Bootstrap: clone this repo and launch the installer.

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_color() {
    printf '%b%s%b\n' "$1" "$2" "${NC}"
}

REPO_URL="${DOTFILES_REPO:-https://github.com/raven-pierce/dotfiles.git}"
DEFAULT_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

print_banner() {
    cat <<'EOF'

  macOS Dotfiles
  --------------
  Clone + interactive component installer

EOF
}

if [[ "$(uname)" != "Darwin" ]]; then
    print_color "${RED}" "This installer is for macOS only"
    exit 1
fi

print_banner

if ! command -v git >/dev/null 2>&1; then
    print_color "${YELLOW}" "Git not found. Installing Xcode Command Line Tools..."
    xcode-select --install
    print_color "${BLUE}" "Finish the Xcode CLT install, then re-run this script"
    exit 1
fi

print_color "${YELLOW}" "Install directory [${DEFAULT_DIR}]:"
if [[ -r /dev/tty ]]; then
    read -r -p "> " INSTALL_DIR </dev/tty || true
elif [[ -t 0 ]]; then
    read -r -p "> " INSTALL_DIR || true
fi
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_DIR}"

if [[ -d "${INSTALL_DIR}" ]]; then
    backup="${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    print_color "${YELLOW}" "Directory exists — moving aside to ${backup}"
    mv "${INSTALL_DIR}" "${backup}"
fi

print_color "${BLUE}" "Cloning ${REPO_URL} → ${INSTALL_DIR}"
git clone "${REPO_URL}" "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

git submodule update --init --recursive
chmod +x scripts/*.sh install

print_color "${CYAN}" "Launching installer (interactive picker on a TTY)..."
echo ""
exec ./scripts/install.sh "$@"
