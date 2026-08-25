setup() {
    cd "${BATS_TEST_DIRNAME}/.."
    source scripts/install.sh
}

@test "--all enables every component and brew group" {
    reset_flags
    parse_args --all
    [ "$flg_Packages" -eq 1 ]
    [ "$flg_Shell" -eq 1 ]
    [ "$flg_Configs" -eq 1 ]
    [ "$flg_WmConfigs" -eq 1 ]
    [ "$flg_Services" -eq 1 ]
    [ "$flg_Macos" -eq 1 ]
    [ "$brew_cli" -eq 1 ]
    [ "$brew_apps" -eq 1 ]
    [ "$brew_wm" -eq 1 ]
    [ "$brew_sbar" -eq 1 ]
}

@test "--no-brew-apps turns the apps group off" {
    reset_flags
    parse_args --packages --no-brew-apps
    [ "$flg_Packages" -eq 1 ]
    [ "$brew_apps" -eq 0 ]
}

@test "--reset-yabai sets the reset flag without components" {
    reset_flags
    parse_args --reset-yabai
    [ "$flg_ResetYabai" -eq 1 ]
    [ "$flg_AnyComponent" -eq 0 ]
}

@test "legacy short flag -i maps to packages" {
    reset_flags
    parse_args -i
    [ "$flg_Packages" -eq 1 ]
}

@test "unknown flag exits non-zero" {
    run bash -c 'cd "'"${BATS_TEST_DIRNAME}"'/.." && source scripts/install.sh && reset_flags && parse_args --nope'
    [ "$status" -ne 0 ]
}

@test "packages selected, groups unset resolves all groups on" {
    reset_flags
    flg_Packages=1
    resolve_brew_groups
    [ "$brew_cli" -eq 1 ]
    [ "$brew_apps" -eq 1 ]
    [ "$brew_wm" -eq 1 ]
    [ "$brew_sbar" -eq 1 ]
}

@test "packages not selected forces all groups off" {
    reset_flags
    resolve_brew_groups
    [ "$brew_cli" -eq 0 ]
    [ "$brew_apps" -eq 0 ]
    [ "$brew_wm" -eq 0 ]
    [ "$brew_sbar" -eq 0 ]
}

@test "packages on with all groups off fails validation" {
    reset_flags
    flg_Packages=1
    brew_cli=0 brew_apps=0 brew_wm=0 brew_sbar=0
    run validate_selection
    [ "$status" -ne 0 ]
}

@test "gum_picker maps selections to component and brew-group flags" {
    reset_flags
    gum() {
        case "$*" in
            *"Select components"*) printf 'Packages (Homebrew Brewfile)\nBase configs (Dotbot)\n' ;;
            *"Homebrew groups"*) printf 'CLI / core tools / fonts\nSketchyBar (lua, luarocks, audio helpers)\n' ;;
        esac
    }
    gum_picker
    [ "$flg_Packages" -eq 1 ]
    [ "$flg_Configs" -eq 1 ]
    [ "$flg_Shell" -eq 0 ]
    [ "$brew_cli" -eq 1 ]
    [ "$brew_apps" -eq 0 ]
    [ "$brew_wm" -eq 0 ]
    [ "$brew_sbar" -eq 1 ]
}

@test "no components + non-interactive exits non-zero (no prompts)" {
    run bash -c '
        cd "'"${BATS_TEST_DIRNAME}"'/.."
        source scripts/install.sh
        is_tty() { return 1; }
        main
    '
    [ "$status" -ne 0 ]
}
