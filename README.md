# dotfiles

My personal configuration files for macOS and Arch Linux. Feel free to use anything you find useful as a starting point for your own setup.

## Structure

Configuration is managed with [GNU Stow](https://www.gnu.org/software/stow/) — each directory is a stow package that mirrors the target directory structure relative to `$HOME`. [just](https://just.systems/) is used as a task runner for installation and setup.

```
dotfiles/
  alacritty-base/     # Alacritty terminal (shared config)
  alacritty-linux/    # Alacritty overrides for Linux
  alacritty-mac/      # Alacritty overrides for macOS
  bin/                # Utility scripts
  certs/              # Custom CA certificate bundle
  claude/             # Claude Code config and statusline
  dunst/              # dunst notification daemon (Arch only)
  dwm/                # dwm config.h (copied into ~/code/dwm at build time)
  fastfetch/          # fastfetch system info config
  ghostty-base/       # Ghostty terminal (shared config)
  ghostty-linux/      # Ghostty overrides for Linux
  ghostty-mac/        # Ghostty overrides for macOS
  git/                # Git config
  gnupg-base/         # GnuPG config (shared)
  gnupg-linux/        # GnuPG overrides for Linux
  gnupg-mac/          # GnuPG overrides for macOS
  hooks/              # Pacman hooks (Arch only, deployed via just)
  irssi/              # irssi IRC client config (server only)
  karabiner/          # Karabiner-Elements key remapping (macOS only)
  keyboard/           # Keyboard layout configs
  keyd/               # keyd key remapping daemon (archbook only)
  mise/               # mise runtime manager config
  modprobe/           # modprobe configs (NVIDIA, iwlwifi — Arch only)
  mpd/                # MPD music player config (archbook only)
  mutt/               # neomutt mail client config (archbook only)
  ncmpcpp/            # ncmpcpp music player config (archbook only)
  network/            # DNS config: systemd-resolved and NetworkManager (Linux only)
  pacman/             # yay AUR helper config (Arch only)
  systemd/            # systemd unit files and hooks (Arch only)
  tin/                # tin terminal client config
  picom/              # picom compositor config (Arch only)
  pipewire-pc/        # PipeWire config for desktop PC
  pipewire-t460s/     # PipeWire config for T460s (archbook)
  redshift/           # redshift color temperature config (Arch only)
  rofi/               # rofi launcher config (Arch only)
  tlp/                # TLP power management config (archbook only)
  tmux/               # tmux config with catppuccin theme
  xorg/               # Xorg configs: keyboard, touchpad, NVIDIA
  yazi/               # yazi file manager config
  zsh/                # zsh config, prompt (powerlevel10k), plugins
```

> **Note:** The migration to just and stow is a work in progress. The repository contains additional loose files and legacy configs that have not yet been reviewed or migrated — mostly because they are not actively used at this time.

## Prerequisites

Install these manually before running anything else:

| Tool | macOS | Arch Linux |
|------|-------|------------|
| [git](https://git-scm.com/) | `brew install git` | `pacman -S git` |
| [just](https://just.systems/) | `brew install just` | `pacman -S just` |
| [stow](https://www.gnu.org/software/stow/) | `brew install stow` | `pacman -S stow` |

## Installation

### 1. Clone the repository

```sh
git clone https://github.com/madhatter/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Arch Linux only: yay and pacman setup

Installs yay from AUR, deploys the pacdiff hook to `/etc/pacman.d/hooks/`, keyboard and touchpad Xorg config to `/etc/X11/xorg.conf.d/`, and stows the yay config:

```sh
just install-arch-setup
```

### 3. Install dependencies

Installs shell tools, prompt framework, and utilities (brew on macOS, yay on Arch):

```sh
just install-deps
```

### 4. Deploy dotfiles

Symlinks all stow packages into `$HOME`:

```sh
just install
```

### 5. Arch Linux only: dwm setup

Builds and installs dwm from `~/code/dwm` using the `config.h` from dotfiles. Requires the dwm repository to be present at `~/code/dwm`:

```sh
just install-dwm-setup
```

### 6. Install tmux plugins

```sh
just install-tmux-plugins
```

---

## Available recipes

```sh
just install              # deploy all stow packages
just uninstall            # remove all stow symlinks
just restow               # re-deploy (useful after adding new files)
just test                 # dry-run to preview what stow would do
just install-deps         # install base tools (OS-aware)
just install-work-deps    # install AWS/cloud tools (macOS only)
just install-tmux-plugins # install tpm and tmux plugins
just install-arch-setup   # Arch only: yay, pacman hook, keyboard and touchpad Xorg config
just install-dwm-setup    # Arch only: build and install dwm from ~/code/dwm
just install-nvidia-setup # Arch only: NVIDIA Xorg and modprobe config (machine-specific, see note below)
just install-irssi        # server only: irssi IRC client
just install-mpd          # archbook only: MPD + ncmpcpp
just deploy-pipewire      # Arch only: PipeWire config (host-aware: archbook vs. PC)
just deploy-keyd          # archbook only: keyd key remapping daemon
just deploy-tlp           # archbook only: TLP power management
just deploy-iwlwifi       # archbook only: iwlwifi modprobe config
just deploy-mail          # archbook only: neomutt mail setup
just deploy-network-setup # Linux only: systemd-resolved and NetworkManager DNS config
just setup-archbook       # full archbook setup: runs all relevant recipes in order
just deploy-alacritty     # deploy Alacritty base + OS-specific overrides
just remove-alacritty     # remove Alacritty symlinks
just deploy-ghostty       # deploy Ghostty base + OS-specific overrides
just remove-ghostty       # remove Ghostty symlinks
just deploy-gnupg         # deploy GnuPG base + OS-specific overrides, set permissions
just remove-gnupg         # remove GnuPG symlinks
```

> **Note on `install-nvidia-setup`:** This recipe deploys hardware-specific configuration files for NVIDIA GPUs and will not be appropriate for every machine. If you are managing multiple systems with different hardware, consider using a proper configuration management tool (Ansible, etc.) instead of applying this blindly.

## Notes

- The zsh prompt uses [powerlevel10k](https://github.com/romkatv/powerlevel10k). Config is in `zsh/.zsh/p10k_prompt.zsh`.
- tmux uses [catppuccin](https://github.com/catppuccin/tmux) (macchiato flavour) with custom purple accents to match the prompt.
- The pacdiff hook opens `nvim -d` after upgrades when `.pacnew` files are present. Change `DIFFPROG` in `hooks/pacdiff.hook` if you prefer a different diff tool.
- fastfetch replaces neofetch/archey and runs on shell login.
- dwm is built from source at `~/code/dwm`. The `config.h` lives in `dotfiles/dwm/` and is copied in at build time, then removed — edit it there, not in the build directory.
- Work dependencies (`awscli`, `vault`, `terraform`) are macOS-only in the Justfile — on Arch these are expected to be managed separately.
- keyd (archbook only) remaps CapsLock+h/j/k/l to arrow keys and is restarted on resume from sleep via a systemd-sleep hook.
- TLP handles battery and power management on the T460s. `systemd-rfkill` and `power-profiles-daemon` are masked to avoid conflicts.
- mutt uses neomutt with fetchmail, procmail, and msmtp. Credentials go in `~/.fetchmailrc` and `~/.msmtprc` — these are not in the repo.
- DNS uses systemd-resolved with Quad9 over TLS (primary) and Mullvad (fallback). NetworkManager is configured to ignore DHCP-provided DNS servers.

## Questions or ideas

madhatter@nostalgix.org
