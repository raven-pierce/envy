#!/usr/bin/env bash
#|---/ /+------------------+---/ /|#
#|--/ /-| Global functions |--/ /-|#
#|-/ /--| ENVY Project     |-/ /--|#
#|/ /---+------------------+/ /---|#

set -e

# Directory variables
scrDir="$(dirname "$(realpath "$0")")"
envyDir="$(dirname "${scrDir}")"
configDir="${envyDir}/configs"
homeDir="${HOME}"
cacheDir="${HOME}/.cache/envy"

# Tool lists
brewList=("brew")
shellList=("zsh")

export scrDir
export envyDir
export configDir
export homeDir
export cacheDir
export brewList
export shellList

# Check if a package is installed via Homebrew
pkg_installed() {
    local pkgName=$1
    
    if brew list "${pkgName}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if a cask is installed via Homebrew
cask_installed() {
    local caskName=$1
    
    if brew list --cask "${caskName}" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if a command exists
command_exists() {
    local cmd=$1
    command -v "${cmd}" >/dev/null 2>&1
}

# Check if Homebrew is installed
homebrew_installed() {
    command_exists brew
}

# Check if Xcode Command Line Tools are installed
xcode_tools_installed() {
    xcode-select -p &>/dev/null
}

# Timer prompt function
prompt_timer() {
    set +e
    unset PROMPT_INPUT
    local timsec=$1
    local msg=$2
    while [[ ${timsec} -ge 0 ]]; do
        echo -ne "\r :: ${msg} (${timsec}s) : "
        read -rt 1 -n 1 PROMPT_INPUT && break
        ((timsec--))
    done
    export PROMPT_INPUT
    echo ""
    set -e
}

# Enhanced logging function with colors
print_log() {
    local logFile="${cacheDir}/logs/$(date +'%y%m%d_%Hh%Mm%Ss').log"
    mkdir -p "$(dirname "${logFile}")"
    
    {
        while (("$#")); do
            case "$1" in
            -r | +r)
                echo -ne "\033[31m$2\033[0m"
                shift 2
                ;; # Red
            -g | +g)
                echo -ne "\033[32m$2\033[0m"
                shift 2
                ;; # Green
            -y | +y)
                echo -ne "\033[33m$2\033[0m"
                shift 2
                ;; # Yellow
            -b | +b)
                echo -ne "\033[34m$2\033[0m"
                shift 2
                ;; # Blue
            -m | +m)
                echo -ne "\033[35m$2\033[0m"
                shift 2
                ;; # Magenta
            -c | +c)
                echo -ne "\033[36m$2\033[0m"
                shift 2
                ;; # Cyan
            -w | +w)
                echo -ne "\033[37m$2\033[0m"
                shift 2
                ;; # White
            -stat)
                echo -ne "\033[30;46m $2 \033[0m :: "
                shift 2
                ;; # Status
            -crit)
                echo -ne "\033[97;41m $2 \033[0m :: "
                shift 2
                ;; # Critical
            -warn)
                echo -ne "WARNING :: \033[30;43m $2 \033[0m :: "
                shift 2
                ;; # Warning
            -info)
                echo -ne "INFO :: \033[30;44m $2 \033[0m :: "
                shift 2
                ;; # Info
            -sec)
                echo -ne "\033[32m[$2] \033[0m"
                shift 2
                ;; # Section
            -err)
                echo -ne "ERROR :: \033[4;31m$2 \033[0m"
                shift 2
                ;; # Error
            *)
                echo -ne "$1"
                shift
                ;;
            esac
        done
        echo ""
    } | tee >(sed 's/\x1b\[[0-9;]*m//g' >>"${logFile}")
}

# Check macOS version compatibility
check_macos_version() {
    local version=$(sw_vers -productVersion)
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    
    print_log -info "macOS Version" "Detected macOS ${version}"
    
    # Check for minimum macOS 12 (Monterey)
    if [[ $major -lt 12 ]]; then
        print_log -err "Compatibility" "ENVY requires macOS 12.0 or later"
        return 1
    fi
    
    return 0
}

# Create backup of existing dotfiles
backup_existing() {
    local target=$1
    local backup_dir="${HOME}/.envy/backups/$(date +'%Y%m%d_%H%M%S')"
    
    if [[ -e "$target" ]]; then
        print_log -warn "Backup" "Creating backup of ${target}"
        mkdir -p "$backup_dir"
        cp -R "$target" "$backup_dir/"
        print_log -g "Success" "Backup created at ${backup_dir}"
    fi
}

# Download and install Oh My Zsh
install_oh_my_zsh() {
    if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
        print_log -info "Oh My Zsh" "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_log -g "Success" "Oh My Zsh installed"
    else
        print_log -y "Skip" "Oh My Zsh already installed"
    fi
}

# Download and install Powerlevel10k
install_powerlevel10k() {
    local p10k_dir="${HOME}/.oh-my-zsh/custom/themes/powerlevel10k"
    
    if [[ ! -d "$p10k_dir" ]]; then
        print_log -info "Powerlevel10k" "Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        print_log -g "Success" "Powerlevel10k installed"
    else
        print_log -y "Skip" "Powerlevel10k already installed"
    fi
}

# Download and install Node Version Manager
install_nvm() {
    if [[ ! -d "${HOME}/.nvm" ]]; then
        print_log -info "NVM" "Installing Node Version Manager..."
        git clone https://github.com/nvm-sh/nvm.git "${HOME}/.nvm"
        cd "${HOME}/.nvm"
        git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
        print_log -g "Success" "NVM installed"
    else
        print_log -y "Skip" "NVM already installed"
    fi
}
