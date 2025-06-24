#!/usr/bin/env bash
#|---/ /+------------------------+---/ /|#
#|--/ /-| SketchyBar setup script |--/ /-|#
#|-/ /--| ENVY Project           |-/ /--|#
#|/ /---+------------------------+/ /---|#

# Source global functions
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/global_fn.sh"

print_log -sec "sketchybar" -info "Starting" "SketchyBar setup and configuration"

# Check if SketchyBar is installed
if ! pkg_installed "sketchybar"; then
    print_log -sec "sketchybar" -err "Missing" "SketchyBar not found! Run package installation first."
    exit 1
fi

# Create fonts directory if it doesn't exist
print_log -sec "sketchybar" -info "Fonts" "Setting up SketchyBar fonts..."
mkdir -p "$HOME/Library/Fonts"

# Download SketchyBar app font
app_font_url="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf"
app_font_path="$HOME/Library/Fonts/sketchybar-app-font.ttf"

if [[ ! -f "$app_font_path" ]]; then
    print_log -sec "sketchybar" -info "Download" "Downloading SketchyBar app font..."
    if curl -L "$app_font_url" -o "$app_font_path"; then
        print_log -sec "sketchybar" -g "Success" "SketchyBar app font installed"
    else
        print_log -sec "sketchybar" -err "Failed" "Could not download SketchyBar app font"
        exit 1
    fi
else
    print_log -sec "sketchybar" -info "Skip" "SketchyBar app font already installed"
fi

# Install SbarLua
print_log -sec "sketchybar" -info "SbarLua" "Installing SbarLua..."

if [[ -d "/tmp/SbarLua" ]]; then
    print_log -sec "sketchybar" -info "Cleanup" "Removing existing SbarLua temporary directory"
    rm -rf /tmp/SbarLua
fi

print_log -sec "sketchybar" -info "Clone" "Cloning SbarLua repository..."
if git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua; then
    print_log -sec "sketchybar" -g "Success" "SbarLua repository cloned"
    
    print_log -sec "sketchybar" -info "Install" "Building and installing SbarLua..."
    cd /tmp/SbarLua/
    
    if make install; then
        print_log -sec "sketchybar" -g "Success" "SbarLua installed successfully"
    else
        print_log -sec "sketchybar" -err "Failed" "SbarLua installation failed"
        exit 1
    fi
    
    # Clean up
    print_log -sec "sketchybar" -info "Cleanup" "Removing temporary SbarLua directory"
    rm -rf /tmp/SbarLua
else
    print_log -sec "sketchybar" -err "Failed" "Could not clone SbarLua repository"
    exit 1
fi

# Check Lua dependencies
print_log -sec "sketchybar" -info "Dependencies" "Checking Lua dependencies..."

if command_exists "lua"; then
    print_log -sec "sketchybar" -g "✓" "Lua runtime available"
else
    print_log -sec "sketchybar" -r "✗" "Lua runtime not found"
fi

if command_exists "luarocks"; then
    print_log -sec "sketchybar" -g "✓" "LuaRocks available"
    
    # Check if lunajson is installed
    if luarocks list | grep -q "lunajson"; then
        print_log -sec "sketchybar" -g "✓" "lunajson already installed"
    else
        print_log -sec "sketchybar" -info "Install" "Installing lunajson..."
        if sudo luarocks install lunajson; then
            print_log -sec "sketchybar" -g "Success" "lunajson installed"
        else
            print_log -sec "sketchybar" -warn "Failed" "Could not install lunajson"
            print_log -sec "sketchybar" -info "Manual" "You may need to run: sudo luarocks install lunajson"
        fi
    fi
else
    print_log -sec "sketchybar" -r "✗" "LuaRocks not found"
    print_log -sec "sketchybar" -info "Install" "Install with: brew install luarocks"
fi

# Check other dependencies
dependencies=(
    "switchaudio-osx"
    "nowplaying-cli"
)

for dep in "${dependencies[@]}"; do
    if command_exists "$dep"; then
        print_log -sec "sketchybar" -g "✓" "${dep} available"
    else
        print_log -sec "sketchybar" -r "✗" "${dep} not found"
    fi
done

print_log -sec "sketchybar" -g "Complete" "SketchyBar setup completed"
print_log -sec "sketchybar" -info "Next" "Run 'brew services restart sketchybar' after dotbot configuration" 