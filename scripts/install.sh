#!/usr/bin/env bash
# macOS dotfiles installer — component-based.

set -euo pipefail

scrDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=global_fn.sh
source "${scrDir}/global_fn.sh"

usage() {
    cat <<EOF
Usage: $0 [options]

Components (select at least one, or use interactive mode on a TTY):
  --packages      Install from Brewfile (see brew group flags below)
  --shell         Set up Oh My Zsh, Powerlevel10k, NVM
  --configs       Link base dotfiles via Dotbot
  --wm-configs    Link window manager configs via Dotbot
  --services      Start window management / SketchyBar services
  --macos         Apply macOS defaults (scripts/macos.sh)
  --all           Enable every component above (all brew groups)

Brew groups (only apply with --packages / --all / interactive packages):
  --brew-cli / --no-brew-cli               Core CLI, fonts (default: on)
  --brew-apps / --no-brew-apps             GUI casks + Mac App Store
  --brew-wm / --no-brew-wm                 yabai / skhd / borders
  --brew-sketchybar / --no-brew-sketchybar SketchyBar, lua, luarocks, audio helpers

Maintenance:
  --reset-yabai   Reinstall the yabai scripting addition (after a yabai upgrade)

Behavior:
  --yes, -y       Accept defaults / skip yes-no prompts where applicable
  --dry-run, -n   Print what would run without making changes
  -h, --help      Show this help

With no component flags:
  - Interactive TTY  → guided component picker (including brew subbundles)
  - Non-interactive  → error (pass flags or --all)

Examples:
  $0                                  # interactive picker
  $0 --packages --shell --configs
  $0 --packages --no-brew-apps --brew-sketchybar --no-brew-wm
  $0 --all --dry-run
  $0 --reset-yabai
EOF
}

flg_Packages=0
flg_Shell=0
flg_Configs=0
flg_WmConfigs=0
flg_Services=0
flg_Macos=0
flg_DryRun=0
flg_AnyComponent=0
flg_ResetYabai=0

# Brew subbundles: -1 = unset (derive from context), 0 = off, 1 = on
brew_cli=-1
brew_apps=-1
brew_wm=-1
brew_sbar=-1

mark_component() {
    flg_AnyComponent=1
}

reset_flags() {
    flg_Packages=0
    flg_Shell=0
    flg_Configs=0
    flg_WmConfigs=0
    flg_Services=0
    flg_Macos=0
    flg_DryRun=0
    flg_AnyComponent=0
    flg_ResetYabai=0
    brew_cli=-1
    brew_apps=-1
    brew_wm=-1
    brew_sbar=-1
    unset use_default 2>/dev/null || true
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --packages | --pkg)
                flg_Packages=1
                mark_component
                shift
                ;;
            --shell)
                flg_Shell=1
                mark_component
                shift
                ;;
            --configs)
                flg_Configs=1
                mark_component
                shift
                ;;
            --wm-configs)
                flg_WmConfigs=1
                mark_component
                shift
                ;;
            --services)
                flg_Services=1
                mark_component
                shift
                ;;
            --macos)
                flg_Macos=1
                mark_component
                shift
                ;;
            --reset-yabai)
                flg_ResetYabai=1
                shift
                ;;
            --brew-cli)
                brew_cli=1
                shift
                ;;
            --no-brew-cli)
                brew_cli=0
                shift
                ;;
            --brew-apps)
                brew_apps=1
                shift
                ;;
            --no-brew-apps)
                brew_apps=0
                shift
                ;;
            --brew-wm)
                brew_wm=1
                shift
                ;;
            --no-brew-wm)
                brew_wm=0
                shift
                ;;
            --brew-sketchybar | --brew-sbar)
                brew_sbar=1
                shift
                ;;
            --no-brew-sketchybar | --no-brew-sbar)
                brew_sbar=0
                shift
                ;;
            --all)
                flg_Packages=1
                flg_Shell=1
                flg_Configs=1
                flg_WmConfigs=1
                flg_Services=1
                flg_Macos=1
                brew_cli=1
                brew_apps=1
                brew_wm=1
                brew_sbar=1
                mark_component
                shift
                ;;
            --yes | -y | -d)
                export use_default="--yes"
                shift
                ;;
            --dry-run | -n | -t)
                flg_DryRun=1
                shift
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            -*)
                opt="${1#-}"
                i=0
                while ((i < ${#opt})); do
                    c="${opt:i:1}"
                    case "$c" in
                        i)
                            flg_Packages=1
                            mark_component
                            ;;
                        r)
                            flg_Configs=1
                            flg_WmConfigs=1
                            mark_component
                            ;;
                        s)
                            flg_Services=1
                            mark_component
                            ;;
                        h)
                            flg_Shell=1
                            mark_component
                            ;;
                        n | t) flg_DryRun=1 ;;
                        d) export use_default="--yes" ;;
                        *)
                            print_log -err "Usage" "Unknown option: -$c"
                            usage
                            exit 1
                            ;;
                    esac
                    ((i++)) || true
                done
                shift
                ;;
            *)
                print_log -err "Usage" "Unexpected argument: $1"
                usage
                exit 1
                ;;
        esac
    done
}

interactive_picker() {
    print_log -b "Picker" "Choose what to install (defaults shown in brackets)"
    echo ""

    if prompt_yes_no "Homebrew packages (Brewfile)" default_yes; then
        flg_Packages=1
        echo ""
        print_log -b "Brew groups" "Select subbundles from the Brewfile"
        if prompt_yes_no "  CLI / core tools / fonts" default_yes; then
            brew_cli=1
        else
            brew_cli=0
        fi
        if prompt_yes_no "  GUI apps (casks + Mac App Store)" default_no; then
            brew_apps=1
        else
            brew_apps=0
        fi
        if prompt_yes_no "  Window management (yabai, skhd, borders)" default_no; then
            brew_wm=1
        else
            brew_wm=0
        fi
        if prompt_yes_no "  SketchyBar (incl. lua, luarocks, audio helpers)" default_no; then
            brew_sbar=1
        else
            brew_sbar=0
        fi
        echo ""
    fi

    if prompt_yes_no "Shell environment (Oh My Zsh, Powerlevel10k, NVM)" default_yes; then
        flg_Shell=1
    fi
    if prompt_yes_no "Base configs (shell, git, nvim, CLI tools via Dotbot)" default_yes; then
        flg_Configs=1
    fi
    if [[ "${brew_wm}" -eq 1 || "${brew_sbar}" -eq 1 ]]; then
        if prompt_yes_no "Window manager / bar configs (yabai/skhd/SketchyBar/borders)" default_yes; then
            flg_WmConfigs=1
        fi
        if prompt_yes_no "Start related services" default_yes; then
            flg_Services=1
        fi
    elif prompt_yes_no "Window manager / bar configs only (no brew WM/SketchyBar group)" default_no; then
        flg_WmConfigs=1
    fi
    if prompt_yes_no "Apply macOS system defaults" default_no; then
        flg_Macos=1
    fi

    flg_AnyComponent=1
}

resolve_brew_groups() {
    if [[ "${flg_Packages}" -eq 1 ]]; then
        [[ "${brew_cli}" -lt 0 ]] && brew_cli=1
        [[ "${brew_apps}" -lt 0 ]] && brew_apps=1
        [[ "${brew_wm}" -lt 0 ]] && brew_wm=1
        [[ "${brew_sbar}" -lt 0 ]] && brew_sbar=1
    else
        brew_cli=0
        brew_apps=0
        brew_wm=0
        brew_sbar=0
    fi
    return 0
}

validate_selection() {
    if [[ "${flg_Packages}" -eq 1 && "${brew_cli}" -eq 0 && "${brew_apps}" -eq 0 && "${brew_wm}" -eq 0 && "${brew_sbar}" -eq 0 ]]; then
        print_log -err "Brewfile" "Packages selected but all brew groups are off"
        return 1
    fi
    return 0
}

describe_plan() {
    print_log -y "DRY RUN" " — no changes will be made"
    [[ "${need_pre}" -eq 1 ]] && print_log -info "Pre" "Would run install_pre.sh (Xcode CLT, Homebrew)"
    if [[ "${flg_Packages}" -eq 1 ]]; then
        print_log -info "Packages" "Would brew bundle Brewfile (cli=${brew_cli} apps=${brew_apps} wm=${brew_wm} sketchybar=${brew_sbar})"
        [[ "${brew_sbar}" -eq 1 ]] && print_log -info "SketchyBar" "Would run install_sketchybar.sh"
    fi
    [[ "${flg_Shell}" -eq 1 ]] && print_log -info "Shell" "Would run install_shell.sh"
    [[ "${flg_Configs}" -eq 1 ]] && print_log -info "Configs" "Would run ./install -c install.conf.yaml"
    [[ "${flg_WmConfigs}" -eq 1 ]] && print_log -info "WM configs" "Would run ./install -c install.wm.conf.yaml"
    [[ "${flg_Macos}" -eq 1 ]] && print_log -info "macOS" "Would run scripts/macos.sh"
    [[ "${flg_Services}" -eq 1 ]] && print_log -info "Services" "Would run install_services.sh"
    return 0
}

main() {
    parse_args "$@"

    if [[ "${flg_ResetYabai}" -eq 1 ]]; then
        exec "${scrDir}/reset_yabai.sh"
    fi

    if [[ "${flg_AnyComponent}" -eq 0 ]]; then
        if is_tty; then
            cat <<'EOF'

  macOS Dotfiles Setup
  --------------------

EOF
            interactive_picker
        else
            print_log -err "Non-interactive" "No component flags given. Pass --all or specific components (see --help)."
            exit 1
        fi
    fi

    resolve_brew_groups
    validate_selection || exit 1

    export flg_DryRun flg_Packages flg_Shell flg_Configs flg_WmConfigs flg_Services flg_Macos
    export DOTFILES_BREW_CLI="${brew_cli}"
    export DOTFILES_BREW_APPS="${brew_apps}"
    export DOTFILES_BREW_WM="${brew_wm}"
    export DOTFILES_BREW_SKETCHYBAR="${brew_sbar}"

    need_pre=0
    if [[ "${flg_Packages}" -eq 1 || "${flg_Configs}" -eq 1 || "${flg_WmConfigs}" -eq 1 ]]; then
        need_pre=1
    fi

    if [[ "${flg_DryRun}" -eq 1 ]]; then
        describe_plan
        exit 0
    fi

    if [[ "$(uname)" != "Darwin" ]]; then
        print_log -err "Platform" "This installer is for macOS only"
        exit 1
    fi

    echo ""
    print_log -info "Plan" "Selected components:"
    [[ "${flg_Packages}" -eq 1 ]] && print_log -g " +" "Packages (cli=${brew_cli} apps=${brew_apps} wm=${brew_wm} sketchybar=${brew_sbar})"
    [[ "${flg_Shell}" -eq 1 ]] && print_log -g " +" "Shell environment"
    [[ "${flg_Configs}" -eq 1 ]] && print_log -g " +" "Base configs"
    [[ "${flg_WmConfigs}" -eq 1 ]] && print_log -g " +" "WM configs"
    [[ "${flg_Macos}" -eq 1 ]] && print_log -g " +" "macOS defaults"
    [[ "${flg_Services}" -eq 1 ]] && print_log -g " +" "Services"
    echo ""

    if [[ "${need_pre}" -eq 1 ]]; then
        print_log -info "Pre-Install" "Running prerequisites..."
        "${scrDir}/install_pre.sh"
    fi

    if [[ "${flg_Packages}" -eq 1 ]]; then
        print_log -info "Packages" "Installing from Brewfile..."
        "${scrDir}/install_pkg.sh"
        if [[ "${brew_sbar}" -eq 1 ]]; then
            print_log -info "SketchyBar" "Setting up SketchyBar dependencies..."
            "${scrDir}/install_sketchybar.sh"
        fi
    fi

    if [[ "${flg_Shell}" -eq 1 ]]; then
        print_log -info "Shell" "Setting up shell environment..."
        "${scrDir}/install_shell.sh"
    fi

    if [[ "${flg_Configs}" -eq 1 ]]; then
        print_log -info "Configs" "Linking base configs..."
        (
            cd "${repoDir}"
            ./install -c install.conf.yaml
        )
    fi

    if [[ "${flg_WmConfigs}" -eq 1 ]]; then
        print_log -info "WM configs" "Linking window manager configs..."
        (
            cd "${repoDir}"
            ./install -c install.wm.conf.yaml
        )
    fi

    if [[ "${flg_Macos}" -eq 1 ]]; then
        print_log -info "macOS" "Applying system defaults..."
        bash "${scrDir}/macos.sh"
    fi

    if [[ "${flg_Services}" -eq 1 ]]; then
        print_log -info "Services" "Configuring services..."
        "${scrDir}/install_services.sh"
    fi

    print_log -g "SUCCESS" "Installation finished"
    print_log -info "Next" "Restart your terminal (or source ~/.zshrc)"
    [[ "${flg_Shell}" -eq 1 ]] && print_log -info "Next" "Run 'p10k configure' to customize your prompt"
    [[ "${flg_Services}" -eq 1 || "${brew_wm}" -eq 1 ]] && print_log -info "Next" "Log out/in so window management picks up Accessibility permissions"
    print_log -info "Docs" "See README.md for customization and key bindings"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
