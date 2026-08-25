# macOS Dotfiles

Personal macOS development environment: Homebrew packages, shell setup, Dotbot-managed configs, and optional window management (yabai / skhd / SketchyBar).

## Features

- Component-based installer (pick what you want)
- Interactive picker on a TTY; non-interactive runs require explicit flags
- One Brewfile with selectable groups (CLI, apps, window management)
- Dotbot for declarative symlinks
- Optional macOS defaults (hostname is never forced)

## Quick start

### Bootstrap

```bash
curl -sSL https://raw.githubusercontent.com/raven-pierce/dotfiles/main/bootstrap.sh | bash
```

Override clone location or repo:

```bash
DOTFILES_DIR=~/.dotfiles DOTFILES_REPO=https://github.com/raven-pierce/dotfiles.git bash <(curl -sSL https://raw.githubusercontent.com/raven-pierce/dotfiles/main/bootstrap.sh)
```

### Manual

```bash
git clone https://github.com/raven-pierce/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive
./scripts/install.sh
```

## Installer

On a terminal with no flags, you get an interactive picker. Away from a TTY (CI, pipes), pass components or `--all`.

```bash
./scripts/install.sh                        # interactive
./scripts/install.sh --packages --shell --configs
./scripts/install.sh --packages --no-brew-apps --brew-sketchybar --no-brew-wm
./scripts/install.sh --wm-configs --services
./scripts/install.sh --all --dry-run
./scripts/install.sh --macos                # system defaults only
COMPUTER_NAME="MyMac" ./scripts/install.sh --macos
```

| Flag | What it does |
|------|----------------|
| `--packages` | Install from root `Brewfile` (see brew groups) |
| `--brew-cli` / `--no-brew-cli` | Toggle CLI / fonts group |
| `--brew-apps` / `--no-brew-apps` | Toggle GUI casks + Mac App Store group |
| `--brew-wm` / `--no-brew-wm` | Toggle yabai / skhd / borders group |
| `--brew-sketchybar` / `--no-brew-sketchybar` | Toggle SketchyBar, lua, luarocks, audio helpers |
| `--shell` | Oh My Zsh, Powerlevel10k, NVM, fzf plugin |
| `--configs` | Base Dotbot links (`install.conf.yaml`) |
| `--wm-configs` | WM Dotbot links (`install.wm.conf.yaml`) |
| `--services` | Start WM services |
| `--macos` | Apply `scripts/macos.sh` defaults |
| `--all` | Everything above (all brew groups on) |
| `--yes` / `-y` | Accept prompt defaults where used |
| `--dry-run` / `-n` | Print the plan only |

Legacy short flags still work: `-i` (packages), `-h` (shell), `-r` (configs), `-s` (services), `-n` (dry-run).

The Brewfile is normal Homebrew Ruby. Groups are gated with `DOTFILES_BREW_CLI`, `DOTFILES_BREW_APPS`, `DOTFILES_BREW_WM`, and `DOTFILES_BREW_SKETCHYBAR` (default `1` if unset), so a plain `brew bundle` still installs everything.

## Layout

```
.
├── bootstrap.sh
├── install                 # Dotbot wrapper (-c CONFIG)
├── install.conf.yaml       # Base configs
├── install.wm.conf.yaml    # Window manager configs
├── Brewfile                # One bundle; groups selectable via env/flags
├── scripts/
│   ├── install.sh          # Orchestrator + picker
│   ├── global_fn.sh
│   ├── install_pre.sh
│   ├── install_pkg.sh
│   ├── install_shell.sh
│   ├── install_services.sh
│   ├── install_sketchybar.sh
│   ├── macos.sh
│   └── reset_yabai.sh
└── configs/                # Linked into $HOME / ~/.config
```

## After install

1. Restart the terminal or `source ~/.zshrc`
2. Run `p10k configure` if you installed the shell stack
3. Log out/in after enabling window management; grant Accessibility if macOS asks
4. Optional full yabai: disable SIP only if you accept the security tradeoff

## Customize

- Packages: edit `Brewfile` (keep the `if cli` / `if apps` / `if wm` / `if sbar` markers), then re-run `--packages` with the group flags you want
- Configs: edit under `configs/`, update the Dotbot YAML, run `./install` or `./install -c install.wm.conf.yaml`
- Hostname during `--macos`: `COMPUTER_NAME=MyMac ./scripts/macos.sh`

## Key bindings

See `configs/skhd/skhdrc` for the full map. Highlights:

| Binding | Action |
|---------|--------|
| `⌥ + H/J/K/L` | Focus window |
| `⇧ + ⌥ + H/J/K/L` | Swap windows |
| `⇧ + ⌥ + F` | Toggle fullscreen |
| `⌃ + ⌥ + B/F/S` | BSP / float / stack layout |

## Troubleshooting

- Homebrew issues: `brew doctor`
- WM not running: `brew services list`; check Accessibility for your terminal / yabai / skhd
- SketchyBar: `./scripts/install_sketchybar.sh` then `brew services restart sketchybar`
- Broken symlinks: `./install` again, or `find ~ -type l -exec test ! -e {} \; -print`

## License

GNU GPLv3 — see [`LICENSE`](LICENSE). Configurations and scripts are provided as-is; fork and remix freely under the license terms.
