# ENVY - macOS Development Environment

**E**nhanced **N**ative **V**irtual **Y**orkspace

ENVY is a complete dotfiles suite that transforms a clean macOS installation into a powerful, aesthetically pleasing development environment. It combines automated scripting with carefully curated configurations to create a modern macOS development workspace.

## ✨ Features

- **🚀 Automated Installation**: One-command setup with bootstrap script or modular installation
- **🎨 Beautiful Aesthetics**: Carefully curated visual configurations for a modern look
- **⚡ Modern Tools**: Latest development tools and CLI replacements
- **🔧 Window Management**: Professional tiling window management with yabai, skhd, and SketchyBar
- **📦 Package Management**: Comprehensive Homebrew setup with 175+ packages and applications
- **🐚 Enhanced Shell**: Zsh with Oh My Zsh, Powerlevel10k, and productivity plugins
- **🔗 Dotfile Management**: Dotbot for declarative and robust configuration management
- **💾 Safe Setup**: Automatic backup handling and dry-run testing

## 🛠 What's Included

### Core Development Tools
- **Editor**: Neovim with LazyVim configuration
- **Terminals**: Ghostty, Warp support with custom configurations
- **Shell**: Zsh with Oh My Zsh, Powerlevel10k, and productivity enhancements
- **Version Control**: Git with enhanced configuration and LazyGit
- **CLI Enhancements**: Modern replacements (bat, eza, ripgrep, fd, fastfetch, btop)

### Window Management System
- **yabai**: Tiling window manager for macOS with BSP, stack, and float layouts
- **skhd**: Hotkey daemon with extensive key bindings
- **SketchyBar**: Custom menu bar with Lua configuration and system monitoring
- **borders**: Window borders and focus indicators

### Development Environment
- **Package Manager**: Homebrew with comprehensive Brewfile (175+ packages)
- **Languages**: Python, Lua with package managers
- **Node.js**: Node Version Manager (NVM) setup
- **Development Services**: Herd, Stripe CLI, Docker integration

### Applications & Tools
- **Code Editors**: Cursor, VS Code, JetBrains Toolbox
- **Git Clients**: GitKraken, Tower
- **Development**: Docker Desktop, OrbStack, Postman, Redis Insight
- **Terminals**: Ghostty, Warp
- **Browsers**: Arc, Firefox
- **Design**: Figma, CleanShot
- **Communication**: Discord, Slack, Zoom
- **Security**: 1Password (CLI and app), Little Snitch
- **System**: Raycast launcher

## 🚀 Quick Start

### Prerequisites
- macOS (tested on recent versions)
- Internet connection for downloading packages
- Administrator access for some installations

### Installation Methods

#### Option 1: Bootstrap Script (Recommended)
```bash
# One-liner installation
curl -sSL https://raw.githubusercontent.com/raven-pierce/envy/main/bootstrap.sh | bash
```

#### Option 2: Manual Installation
```bash
# Clone the repository
git clone https://github.com/raven-pierce/envy.git ~/.envy
cd ~/.envy

# Initialize Dotbot submodule
git submodule update --init --recursive

# Run full installation
./scripts/install.sh
```

#### Option 3: Custom Installation
```bash
# Test what would be installed (dry run)
./scripts/install.sh -n

# Install packages only
./scripts/install.sh -i

# Setup shell environment only
./scripts/install.sh -h

# Restore configurations only
./scripts/install.sh -r

# Configure services only
./scripts/install.sh -s

# Full installation with all components
./scripts/install.sh -irsh
```

### Installation Options

| Flag | Description |
|------|-------------|
| `-i` | Install packages via Homebrew from Brewfile |
| `-d` | Install with defaults (no interactive prompts) |
| `-r` | Restore configuration files using Dotbot |
| `-s` | Configure services and system preferences |
| `-h` | Setup shell environment (zsh, Oh My Zsh, Powerlevel10k) |
| `-n` | Dry run mode (test without executing changes) |
| `-t` | Test run (same as -n) |

## 📁 Project Structure

```
ENVY/
├── bootstrap.sh             # Quick installer/bootstrap script
├── install                  # Dotbot installation wrapper
├── install.conf.yaml       # Dotbot configuration for symlinking
├── Brewfile                # Homebrew packages (175+ formulae/casks)
├── scripts/                # Installation and management scripts
│   ├── global_fn.sh        # Shared functions and utilities
│   ├── install.sh          # Main installation orchestrator
│   ├── install_pre.sh      # Prerequisites (Xcode tools, Homebrew)
│   ├── install_pkg.sh      # Package installation via Homebrew
│   ├── install_shell.sh    # Shell environment setup (zsh, Oh My Zsh)
│   ├── install_services.sh # System services and preferences
│   └── install_sketchybar.sh # SketchyBar specific setup
├── configs/                # Configuration files for all tools
│   ├── shell/              # Zsh shell configuration
│   │   ├── zshrc          # Main zsh configuration
│   │   ├── zprofile       # Zsh profile settings
│   │   └── aliases/       # Command aliases organized by category
│   ├── nvim/              # Neovim with LazyVim configuration
│   ├── git/               # Git configuration and global gitignore
│   ├── yabai/             # Window manager configuration
│   ├── skhd/              # Hotkey daemon configuration
│   ├── sketchybar/        # Menu bar configuration (Lua-based)
│   ├── borders/           # Window border configuration
│   ├── bat/               # Bat (cat replacement) configuration
│   ├── fastfetch/         # System information tool configuration
│   └── yazi/              # File manager configuration
└── dotbot/                # Dotbot submodule for config management
```

## 🎯 Post-Installation

After installation, complete these steps:

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Configure Powerlevel10k** by running `p10k configure`
3. **Log out and back in** to activate window management
4. **Optional: Disable SIP** for full yabai functionality:
   - Boot into Recovery Mode (⌘+R during startup)
   - Open Terminal in Recovery Mode
   - Run: `csrutil disable`
   - Reboot normally
   - Note: This reduces system security, consider implications

5. **Start window management services** (if not auto-started):
   ```bash
   brew services start yabai
   brew services start skhd
   brew services start sketchybar
   brew services start borders
   ```

## 🔧 Key Bindings

ENVY includes comprehensive key bindings for window management:

### Application Shortcuts
| Binding | Action |
|---------|--------|
| `⌘ + ⌥ + Return` | Open terminal (Warp) |

### Window Focus
| Binding | Action |
|---------|--------|
| `⌥ + H/J/K/L` | Focus window (left/down/up/right) |
| `⌥ + E/W` | Focus external display (east/west) |

### Window Management
| Binding | Action |
|---------|--------|
| `⇧ + ⌥ + T` | Toggle window float |
| `⇧ + ⌥ + F` | Toggle fullscreen |
| `⇧ + ⌥ + E` | Balance windows |
| `⇧ + ⌥ + R` | Rotate layout clockwise |
| `⇧ + ⌥ + Y/X` | Mirror along y/x axis |

### Window Movement
| Binding | Action |
|---------|--------|
| `⇧ + ⌥ + H/J/K/L` | Swap windows |
| `⌃ + ⌥ + H/J/K/L` | Move window and split |
| `⇧ + ⌥ + 1-5` | Move window to space |

### Layout Control
| Binding | Action |
|---------|--------|
| `⌃ + ⌥ + B` | BSP layout |
| `⌃ + ⌥ + F` | Float layout |
| `⌃ + ⌥ + S` | Stack layout |

### Stacking
| Binding | Action |
|---------|--------|
| `⇧ + ⌃ + H/J/K/L` | Stack windows |

*Complete key bindings can be found in `configs/skhd/skhdrc`*

## 🎨 Customization

### Adding New Configurations

1. Add your configuration files to the appropriate directory in `configs/`
2. Update `install.conf.yaml` to include the new symlinks
3. Run `./install` to apply changes

Example:
```yaml
- link:
    ~/.config/mynewapp: configs/mynewapp
```

### Modifying Existing Configurations

Configurations are symbolically linked, so you can edit them directly in the `configs/` directory and changes take effect immediately.

### Adding New Packages

Edit the `Brewfile` to add new packages:
```bash
# Add to Brewfile
echo 'brew "new-package"' >> Brewfile

# Install new packages
brew bundle install --file=Brewfile
```

### Shell Customization

- **Aliases**: Add new aliases in `configs/shell/aliases/`
- **Zsh Config**: Modify `configs/shell/zshrc`
- **Profile**: Update `configs/shell/zprofile`

## 🐛 Troubleshooting

### Common Issues

**Homebrew installation fails**
- Ensure stable internet connection
- Verify Xcode Command Line Tools: `xcode-select --install`
- Check available disk space

**Window management not working**
- Verify services are running: `brew services list | grep -E "(yabai|skhd|sketchybar|borders)"`
- Check System Preferences → Security & Privacy → Accessibility
- Add terminal app to Privacy → Accessibility
- Consider disabling SIP for full yabai functionality

**SketchyBar not displaying**
- Ensure Lua dependencies are installed: `./scripts/install_sketchybar.sh`
- Check SketchyBar service: `brew services restart sketchybar`
- Verify font installation

**Configurations not applying**
- Re-run Dotbot: `./install`
- Check for broken symlinks: `find ~ -type l -exec test ! -e {} \; -print`
- Verify file permissions for window manager configs

### Logs and Debugging

- Installation logs are available during script execution
- Use dry run mode to test: `./scripts/install.sh -n`
- Check Homebrew issues: `brew doctor`
- Verify service logs: `brew services list`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Update documentation if needed
5. Submit a pull request with a clear description

### Development Guidelines

- Test installations in a clean environment
- Update the README when adding new features
- Follow existing code style in scripts
- Document new configuration options

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Dotbot**: Excellent dotfile management framework
- **LazyVim**: Modern Neovim configuration
- **SketchyBar**: Powerful menu bar replacement
- **yabai**: Excellent tiling window manager for macOS
- The entire open-source community for the amazing tools that make this possible

## 🌟 Star History

If you find ENVY useful, please consider giving it a star! ⭐

---

**Happy coding!** 🚀

For issues, feature requests, or questions, please open an issue on GitHub. 