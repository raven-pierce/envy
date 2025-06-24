#!/usr/bin/env bash
#|---/ /+--------------------------+---/ /|#
#|--/ /-| Main installation script |--/ /-|#
#|-/ /--| ENVY Project             |-/ /--|#
#|/ /---+--------------------------+/ /---|#

cat <<"EOF"

-------------------------------------------------
    ███████╗███╗   ██╗██╗   ██╗██╗   ██╗
    ██╔════╝████╗  ██║██║   ██║╚██╗ ██╔╝
    █████╗  ██╔██╗ ██║██║   ██║ ╚████╔╝ 
    ██╔══╝  ██║╚██╗██║╚██╗ ██╔╝  ╚██╔╝  
    ███████╗██║ ╚████║ ╚████╔╝    ██║   
    ╚══════╝╚═╝  ╚═══╝  ╚═══╝     ╚═╝   
                                        
    macOS Development Environment Setup
-------------------------------------------------

EOF

#--------------------------------#
# import variables and functions #
#--------------------------------#
scrDir="$(dirname "$(realpath "$0")")"
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

#------------------#
# evaluate options #
#------------------#
flg_Install=0
flg_Restore=0
flg_Service=0
flg_Shell=0
flg_DryRun=0

while getopts "idrshnt" RunStep; do
    case $RunStep in
    i) flg_Install=1 ;;
    d)
        flg_Install=1
        export use_default="--yes"
        ;;
    r) flg_Restore=1 ;;
    s) flg_Service=1 ;;
    h) flg_Shell=1 ;;
    n) flg_DryRun=1 ;;
    t) flg_DryRun=1 ;;
    *)
        cat <<EOF
Usage: $0 [options]
            i : [i]nstall packages via Homebrew
            d : install with [d]efaults (no prompts)
            r : [r]estore configuration files
            s : configure [s]ervices and system preferences
            h : setup s[h]ell environment (zsh, Oh My Zsh, etc.)
            n : [n]o execute / dry run mode
            t : [t]est run (same as -n)

Examples:
        install.sh              # Full installation (equivalent to -irsh)
        install.sh -i           # Install packages only
        install.sh -r           # Restore configs only
        install.sh -irsh        # Full installation with all components
        install.sh -n           # Dry run to see what would be executed

EOF
        exit 1
        ;;
    esac
done

# Export flags for use in other scripts
export flg_DryRun flg_Install flg_Restore flg_Service flg_Shell

# Default to full installation if no options specified
if [ $OPTIND -eq 1 ]; then
    flg_Install=1
    flg_Restore=1
    flg_Service=1
    flg_Shell=1
    print_log -info "Default" "Running full ENVY installation"
fi

if [ "${flg_DryRun}" -eq 1 ]; then
    print_log -y "DRY RUN" "Test mode enabled - no actual changes will be made"
    print_log -info "Actions" "The following would be executed:"
    
    if [ "${flg_Install}" -eq 1 ] || [ "${flg_Restore}" -eq 1 ]; then
        print_log -info "Pre-Install" "Would run: ${scrDir}/install_pre.sh"
        print_log -info "  →" "Check macOS compatibility"
        print_log -info "  →" "Install Xcode Command Line Tools (if needed)"
        print_log -info "  →" "Install Homebrew (if needed)"
        print_log -info "  →" "Update Homebrew"
    fi
    
    if [ "${flg_Install}" -eq 1 ]; then
        print_log -info "Packages" "Would run: ${scrDir}/install_pkg.sh"
        print_log -info "  →" "Install packages from Brewfile via: brew bundle install --file=${envyDir}/Brewfile"
        print_log -info "  →" "Verify critical packages are available"
        print_log -info "SketchyBar" "Would run: ${scrDir}/install_sketchybar.sh"
        print_log -info "  →" "Download SketchyBar app font"
        print_log -info "  →" "Install SbarLua"
        print_log -info "  →" "Install lunajson Lua dependency"
    fi
    
    if [ "${flg_Shell}" -eq 1 ]; then
        print_log -info "Shell" "Would run: ${scrDir}/install_shell.sh"
        print_log -info "  →" "Install Oh My Zsh"
        print_log -info "  →" "Install Powerlevel10k theme"
        print_log -info "  →" "Install Node Version Manager (NVM)"
        print_log -info "  →" "Install fzf-zsh-plugin"
        print_log -info "  →" "Set zsh as default shell (if needed)"
    fi
    
    if [ "${flg_Restore}" -eq 1 ]; then
        print_log -info "Restore" "Would run: ./install (Dotbot)"
        print_log -info "  →" "Create symbolic links for all configurations"
        print_log -info "  →" "Create required directories"
        print_log -info "  →" "Set executable permissions for window manager configs"
        print_log -info "  →" "Clean up broken symlinks"
    fi
    
    if [ "${flg_Service}" -eq 1 ]; then
        print_log -info "Services" "Would run: ${scrDir}/install_services.sh"
        print_log -info "  →" "Configure macOS system preferences"
        print_log -info "  →" "Start Homebrew services (yabai, skhd, sketchybar, borders)"
        print_log -info "  →" "Enable login services"
        print_log -info "  →" "Check SIP status"
    fi
    
    print_log ""
    print_log -g "Note" "To run the actual installation, remove the -n flag"
    exit 0
fi

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    print_log -err "Platform" "ENVY is designed for macOS only"
    exit 1
fi

#--------------------#
# pre-install script #
#--------------------#
if [ ${flg_Install} -eq 1 ] || [ ${flg_Restore} -eq 1 ]; then
    cat <<"EOF"
                _         _       _ _
 ___ ___ ___   |_|___ ___| |_ ___| | |
| . |  _| -_|  | |   |_ -|  _| .'| | |
|  _|_| |___|  |_|_|_|___|_| |__,|_|_|
|_|

EOF

    print_log -info "Pre-Install" "Running pre-installation setup..."
    "${scrDir}/install_pre.sh"
fi

#------------#
# installing #
#------------#
if [ ${flg_Install} -eq 1 ]; then
    cat <<"EOF"

 _         _       _ _ _
|_|___ ___| |_ ___| | |_|___ ___
| |   |_ -|  _| .'| | | |   | . |
|_|_|_|___|_| |__,|_|_|_|_|_|_  |
                            |___|

EOF

    print_log -info "Install" "Starting package installation..."
    "${scrDir}/install_pkg.sh"
    
    # SketchyBar specific setup
    print_log -info "SketchyBar" "Setting up SketchyBar dependencies..."
    "${scrDir}/install_sketchybar.sh"
fi

#-------------------#
# shell environment #
#-------------------#
if [ ${flg_Shell} -eq 1 ]; then
    cat <<"EOF"

     _         _ _
 ___| |_ ___ | | |
|_ -|   | -_|| | |
|___|_|_|___||_|_|

EOF

    print_log -info "Shell" "Setting up shell environment..."
    "${scrDir}/install_shell.sh"
fi

#----------#
# restoring #
#----------#
if [ ${flg_Restore} -eq 1 ]; then
    cat <<"EOF"

             _
 ___ ___ ___| |_ ___ ___ ___
|  _| -_|_ -|  _| . |  _| -_|
|_| |___|___|_| |___|_| |___|

EOF

    print_log -info "Restore" "Running Dotbot configuration restoration..."
    cd "${envyDir}"
    if [ "${flg_DryRun}" -eq 1 ]; then
        print_log -info "Dotbot" "Would run: ./install"
    else
        ./install
    fi
fi


#----------#
# services #
#----------#
if [ ${flg_Service} -eq 1 ]; then
    cat <<"EOF"

                     _
 ___ ___ ___ _ _ _____|_|___ ___ ___
|_ -| -_|  _| | | | | |  _| -_|_ -|
|___|___|_|  \_/|_|_|_|___|___|___|

EOF

    print_log -info "Services" "Configuring services and system preferences..."
    "${scrDir}/install_services.sh"
fi

#------------#
# completion #
#------------#
cat <<"EOF"

     ___ ___ _____ ___ _    ___ _____ ___ 
    |  _|   |     |  _| |  | __|_   _| __|
    |  _| | | | | |  _| |__|   | | | |   |
    |___|___| |_|_|___|____|___| |_| |___|

EOF

print_log -g "SUCCESS" "ENVY installation completed successfully!"
print_log ""
print_log -info "What's Next?" "Here are some next steps to get you started:"
print_log ""
print_log -b "Terminal:" "Restart your terminal or run 'source ~/.zshrc'"
print_log -b "Prompt:" "Run 'p10k configure' to customize your Powerlevel10k prompt"
print_log -b "Window Manager:" "Log out and log back in to activate yabai and skhd"
print_log -b "Neovim:" "Run 'nvim' to start configuring your development environment"
print_log ""

# Display installed components
print_log -info "Installed Components:" ""
[ "${flg_Install}" -eq 1 ] && print_log -g "✓" "Homebrew packages and applications"
[ "${flg_Shell}" -eq 1 ] && print_log -g "✓" "Oh My Zsh, Powerlevel10k, and NVM"
[ "${flg_Restore}" -eq 1 ] && print_log -g "✓" "Configuration files and dotfiles"
[ "${flg_Service}" -eq 1 ] && print_log -g "✓" "macOS preferences and services"

print_log ""
print_log -info "Documentation:" "Check the README.md for detailed configuration guides"
print_log -info "Issues?" "Report problems at: https://github.com/raven-pierce/envy/issues"
print_log ""
print_log -c "Enjoy your new development environment!" "🚀" 