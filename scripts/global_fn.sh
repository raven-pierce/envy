#!/usr/bin/env bash
# Shared helpers for the macOS dotfiles installer.

set -euo pipefail

scrDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repoDir="$(cd "${scrDir}/.." && pwd)"
configDir="${repoDir}/configs"
homeDir="${HOME}"
cacheDir="${XDG_CACHE_HOME:-${HOME}/.cache}/dotfiles"

export scrDir repoDir configDir homeDir cacheDir

pkg_installed() {
    local pkgName=$1
    brew list --formula "${pkgName}" &>/dev/null || brew list --cask "${pkgName}" &>/dev/null
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

homebrew_installed() {
    command_exists brew
}

xcode_tools_installed() {
    xcode-select -p &>/dev/null
}

is_tty() {
    # Prefer a real controlling terminal so curl|bash still gets a picker.
    [[ -r /dev/tty && -w /dev/tty ]] || [[ -t 0 && -t 1 ]]
}

has_gum() {
    command -v gum >/dev/null 2>&1
}

ui_rich() {
    # Rich gum UI only when not in --yes mode, gum is present, and interactive.
    [[ "${use_default:-}" != "--yes" ]] && has_gum && is_tty
}

prompt_yes_no() {
    # prompt_yes_no "Question" default_yes|default_no
    local prompt=$1
    local default=${2:-default_yes}
    local reply
    local tty_in=/dev/tty

    if [[ "${use_default:-}" == "--yes" ]]; then
        [[ "${default}" == "default_yes" ]] && return 0 || return 1
    fi

    if ui_rich; then
        local gum_default=true
        [[ "${default}" == "default_no" ]] && gum_default=false
        if gum confirm --default="${gum_default}" "${prompt}"; then
            return 0
        else
            return 1
        fi
    fi

    if [[ ! -r "${tty_in}" ]]; then
        tty_in=/dev/stdin
    fi

    if [[ "${default}" == "default_yes" ]]; then
        read -r -p "${prompt} [Y/n] " reply <"${tty_in}" || true
        [[ -z "${reply}" || "${reply}" =~ ^[Yy]$ ]]
    else
        read -r -p "${prompt} [y/N] " reply <"${tty_in}" || true
        [[ "${reply}" =~ ^[Yy]$ ]]
    fi
}

prompt_input() {
    # prompt_input "Label" "default" -> echoes entered value (or default)
    local label=$1
    local default=${2:-}
    local reply

    if [[ "${use_default:-}" == "--yes" ]] || ! is_tty; then
        printf '%s' "${default}"
        return 0
    fi

    if ui_rich; then
        gum input --prompt "${label}: " --value "${default}" --placeholder "${default}"
        return 0
    fi

    read -r -p "${label} [${default}]: " reply </dev/tty || true
    printf '%s' "${reply:-${default}}"
}

print_section() {
    local title=$1
    if ui_rich; then
        gum style --border rounded --padding "0 1" --margin "1 0" \
            --border-foreground 212 "${title}"
    else
        print_log -b "==>" "${title}"
    fi
}

print_log() {
    local logDir="${cacheDir}/logs"
    local logFile=""
    local use_log=0

    if mkdir -p "${logDir}" 2>/dev/null; then
        logFile="${logDir}/$(date +'%y%m%d_%Hh%Mm%Ss').log"
        use_log=1
    fi

    format_line() {
        while (("$#")); do
            case "$1" in
                -r | +r)
                    printf '\033[31m%s\033[0m' "$2"
                    shift 2
                    ;;
                -g | +g)
                    printf '\033[32m%s\033[0m' "$2"
                    shift 2
                    ;;
                -y | +y)
                    printf '\033[33m%s\033[0m' "$2"
                    shift 2
                    ;;
                -b | +b)
                    printf '\033[34m%s\033[0m' "$2"
                    shift 2
                    ;;
                -m | +m)
                    printf '\033[35m%s\033[0m' "$2"
                    shift 2
                    ;;
                -c | +c)
                    printf '\033[36m%s\033[0m' "$2"
                    shift 2
                    ;;
                -w | +w)
                    printf '\033[37m%s\033[0m' "$2"
                    shift 2
                    ;;
                -stat)
                    printf '\033[30;46m %s \033[0m :: ' "$2"
                    shift 2
                    ;;
                -crit)
                    printf '\033[97;41m %s \033[0m :: ' "$2"
                    shift 2
                    ;;
                -warn)
                    printf 'WARNING :: \033[30;43m %s \033[0m :: ' "$2"
                    shift 2
                    ;;
                -info)
                    printf 'INFO :: \033[30;44m %s \033[0m :: ' "$2"
                    shift 2
                    ;;
                -sec)
                    printf '\033[32m[%s] \033[0m' "$2"
                    shift 2
                    ;;
                -err)
                    printf 'ERROR :: \033[4;31m%s \033[0m' "$2"
                    shift 2
                    ;;
                *)
                    printf '%s' "$1"
                    shift
                    ;;
            esac
        done
        printf '\n'
    }

    if [[ "${use_log}" -eq 1 ]]; then
        format_line "$@" | tee >(sed 's/\x1b\[[0-9;]*m//g' >>"${logFile}")
    else
        format_line "$@"
    fi
}

check_macos_version() {
    local version major
    version="$(sw_vers -productVersion)"
    major="$(printf '%s' "${version}" | cut -d. -f1)"

    print_log -info "macOS Version" "Detected macOS ${version}"

    if [[ "${major}" -lt 12 ]]; then
        print_log -err "Compatibility" "Requires macOS 12.0 or later"
        return 1
    fi
    return 0
}

backup_existing() {
    local target=$1
    local backup_dir
    backup_dir="${repoDir}/backups/$(date +'%Y%m%d_%H%M%S')"

    if [[ -e "${target}" ]]; then
        print_log -warn "Backup" "Creating backup of ${target}"
        mkdir -p "${backup_dir}"
        cp -R "${target}" "${backup_dir}/"
        print_log -g "Success" "Backup created at ${backup_dir}"
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        print_log -info "Oh My Zsh" "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_log -g "Success" "Oh My Zsh installed"
    else
        print_log -y "Skip" "Oh My Zsh already installed"
    fi
}

install_powerlevel10k() {
    local p10k_dir="${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"

    if [[ ! -d "${p10k_dir}" ]]; then
        print_log -info "Powerlevel10k" "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${p10k_dir}"
        print_log -g "Success" "Powerlevel10k installed"
    else
        print_log -y "Skip" "Powerlevel10k already installed"
    fi
}

install_nvm() {
    if [[ ! -d "${HOME}/.nvm" ]]; then
        print_log -info "NVM" "Installing Node Version Manager..."
        git clone https://github.com/nvm-sh/nvm.git "${HOME}/.nvm"
        (
            cd "${HOME}/.nvm"
            git checkout "$(git describe --abbrev=0 --tags --match 'v[0-9]*' "$(git rev-list --tags --max-count=1)")"
        )
        print_log -g "Success" "NVM installed"
    else
        print_log -y "Skip" "NVM already installed"
    fi
}

run_brewfile() {
    local brewfile=$1
    if [[ ! -f "${brewfile}" ]]; then
        print_log -err "Missing" "Brewfile not found: ${brewfile}"
        return 1
    fi
    print_log -info "Brewfile" "Installing from ${brewfile}"
    brew bundle install --file="${brewfile}"
}
