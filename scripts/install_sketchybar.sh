#!/usr/bin/env bash
# SketchyBar fonts and Lua helpers.

set -euo pipefail

scrDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=global_fn.sh
source "${scrDir}/global_fn.sh"
enable_error_trap

print_log -sec "sketchybar" -info "Starting" "SketchyBar setup"

if ! pkg_installed "sketchybar"; then
    print_log -sec "sketchybar" -err "Missing" "SketchyBar not found! Install the SketchyBar brew group first."
    exit 1
fi

mkdir -p "${HOME}/Library/Fonts"

app_font_url="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf"
app_font_path="${HOME}/Library/Fonts/sketchybar-app-font.ttf"

if [[ ! -f "${app_font_path}" ]]; then
    print_log -sec "sketchybar" -info "Download" "Downloading SketchyBar app font..."
    if curl -fsSL "${app_font_url}" -o "${app_font_path}"; then
        print_log -sec "sketchybar" -g "Success" "App font installed"
    else
        print_log -sec "sketchybar" -err "Failed" "Could not download SketchyBar app font"
        exit 1
    fi
else
    print_log -sec "sketchybar" -y "Skip" "App font already installed"
fi

print_log -sec "sketchybar" -info "SbarLua" "Installing SbarLua..."
rm -rf /tmp/SbarLua
if git clone --depth 1 https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua; then
    (
        cd /tmp/SbarLua
        make install
    )
    rm -rf /tmp/SbarLua
    print_log -sec "sketchybar" -g "Success" "SbarLua installed"
else
    print_log -sec "sketchybar" -err "Failed" "Could not clone SbarLua"
    exit 1
fi

if command_exists luarocks; then
    if luarocks list 2>/dev/null | grep -q "lunajson"; then
        print_log -sec "sketchybar" -g "ok" "lunajson already installed"
    else
        print_log -sec "sketchybar" -info "Install" "Installing lunajson..."
        if ! sudo luarocks install lunajson; then
            print_log -sec "sketchybar" -warn "Failed" "Could not install lunajson (try: sudo luarocks install lunajson)"
        fi
    fi
else
    print_log -sec "sketchybar" -warn "Missing" "luarocks not found"
fi

for dep in switchaudio-osx nowplaying-cli; do
    if command_exists "${dep}"; then
        print_log -sec "sketchybar" -g "ok" "${dep}"
    else
        print_log -sec "sketchybar" -y "missing" "${dep}"
    fi
done

print_log -sec "sketchybar" -g "Complete" "SketchyBar setup completed"
