setup() {
    cd "${BATS_TEST_DIRNAME}/.."
    source scripts/brewfile.sh
    FIXTURE="${BATS_TEST_TMPDIR}/Brewfile"
    cat >"${FIXTURE}" <<'EOF'
cli = ENV.fetch("DOTFILES_BREW_CLI", "1") == "1"
tap "felixkratz/formulae" if sbar || wm
brew "gum" if cli
cask "raycast" if apps
mas "Xcode", id: 497799835 if apps
brew "yabai" if wm # required:wm-configs,services
brew "borders" if wm
brew "sketchybar" if sbar # required:wm-configs,services
EOF
}

@test "candidates for wm list yabai and borders" {
    run brewfile_candidates "${FIXTURE}" wm
    [[ "${output}" == *"yabai"* ]]
    [[ "${output}" == *"borders"* ]]
}

@test "candidates carry the required marker" {
    run brewfile_candidates "${FIXTURE}" wm
    [[ "${output}" == *"wm-configs,services"* ]]
}

@test "candidates exclude other groups" {
    run brewfile_candidates "${FIXTURE}" wm
    [[ "${output}" != *"raycast"* ]]
    [[ "${output}" != *"gum"* ]]
}

@test "mas spec is preserved verbatim" {
    run brewfile_candidates "${FIXTURE}" apps
    [[ "${output}" == *'"Xcode", id: 497799835'* ]]
}

@test "generate keeps selected packages plus active taps, drops the rest" {
    keep="${BATS_TEST_TMPDIR}/keep"
    printf 'brew:yabai\n' >"${keep}"
    run brewfile_generate "${FIXTURE}" 0 0 1 0 "${keep}"
    [[ "${output}" == *'brew "yabai"'* ]]
    [[ "${output}" == *'tap "felixkratz/formulae"'* ]]
    [[ "${output}" != *"borders"* ]]
}

@test "generate excludes packages from disabled groups" {
    keep="${BATS_TEST_TMPDIR}/keep"
    printf 'cask:raycast\n' >"${keep}"
    run brewfile_generate "${FIXTURE}" 1 0 0 0 "${keep}"
    [[ "${output}" != *"raycast"* ]]
}

@test "generated filtered Brewfile has no ruby conditionals" {
    keep="${BATS_TEST_TMPDIR}/keep"
    printf 'brew:gum\n' >"${keep}"
    run brewfile_generate "${FIXTURE}" 1 0 0 0 "${keep}"
    [[ "${output}" != *" if "* ]]
    [[ "${output}" != *"ENV.fetch"* ]]
}
