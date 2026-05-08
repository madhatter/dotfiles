# Determine the operating system and hostname
os_name := `uname -s`
hostname := `command -v hostnamectl > /dev/null 2>&1 && hostnamectl hostname || hostname`

# Define the list of packages to manage with stow
packages := if os_name == "Darwin" { "certs claude fastfetch git karabiner mise tmux zsh"
} else { "claude dunst fastfetch git mise picom redshift rofi tmux yazi zsh" }

# General recipes for managing dotfiles with stow
install: deploy-alacritty deploy-ghostty deploy-gnupg
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" {{packages}}

uninstall: remove-alacritty remove-ghostty remove-gnupg
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" -D {{packages}}

restow: deploy-alacritty deploy-ghostty
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" -R {{packages}}

test:
    stow -nv -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" {{packages}}

# Install base dependencies (shell tools, prompt, utilities)
install-deps:
    @if [ "{{os_name}}" = "Darwin" ]; then \
        echo "Installing dependencies via Homebrew..."; \
        brew install powerlevel10k fzf direnv mise jq oath-toolkit fastfetch alacritty vivid gnupg pinentry-mac ghostty; \
    else \
        echo "Installing dependencies via pacman..."; \
        yay -S --needed zsh-theme-powerlevel10k fzf direnv mise jq oath-toolkit fastfetch xclip alacritty vivid rofi rofi-calc papirus-icon-theme picom slock xss-lock gnupg pinentry redshift ghostty dunst neomutt msmtp fetchmail procmail urlscan w3m; \
    fi

# Install work-related dependencies (AWS, cloud, infra tools) — macOS only
install-work-deps:
    @if [ "{{os_name}}" = "Darwin" ]; then \
        echo "Installing work dependencies via Homebrew..."; \
        brew install awscli terraform vault; \
        pip3 install aws-sso-util awsume; \
    else \
        echo "This recipe is only for macOS."; \
        exit 1; \
    fi

# Arch Linux only: install yay, deploy pacman hook and yay config
install-arch-setup:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if ! command -v yay >/dev/null 2>&1; then \
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && \
        cd /tmp/yay-bin && makepkg -si --noconfirm && \
        rm -rf /tmp/yay-bin; \
    else \
        echo "yay already installed"; \
    fi
    sudo pacman -S --needed pacman-contrib
    sudo install -Dm644 {{justfile_directory()}}/hooks/pacdiff.hook \
        /etc/pacman.d/hooks/pacdiff.hook
    sudo install -Dm644 {{justfile_directory()}}/xorg/00-keyboard.conf \
        /etc/X11/xorg.conf.d/00-keyboard.conf
    sudo install -Dm644 {{justfile_directory()}}/xorg/30-touchpad.conf \
        /etc/X11/xorg.conf.d/30-touchpad.conf
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" pacman
    @if [ "{{hostname}}" = "archbook" ]; then \
        echo "T460s detected. Deploying T460s configurations..."; \
        sudo install -Dm644 {{justfile_directory()}}/systemd/disable-usb-wakeup.service \
            /etc/systemd/system/disable-usb-wakeup.service; \
        sudo systemctl enable --now disable-usb-wakeup; \
    fi

# Also Arch Linux only: install NVIDIA Xorg configuration and modprobe settings
install-nvidia-setup:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    sudo install -Dm644 {{justfile_directory()}}/xorg/10-nvidia-drm-outputclass.conf \
        /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf
    sudo install -Dm644 {{justfile_directory()}}/xorg/xorg.conf \
        /etc/X11/xorg.conf
    sudo install -Dm644 {{justfile_directory()}}/modprobe/nvidia-drm-nomodeset.conf \
        /etc/modprobe.d/nvidia-drm-nomodeset.conf

# More Arch Linux-only parts: dwm windowmanager setup
install-dwm-setup:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if [ ! -d "{{env_var('HOME')}}/code/dwm" ]; then \
        echo "~/code/dwm not found, skipping dwm build."; \
        exit 1; \
    fi
    cp {{justfile_directory()}}/dwm/config.h {{env_var('HOME')}}/code/dwm/config.h
    cd {{env_var('HOME')}}/code/dwm && makepkg -sCfi
    rm {{env_var('HOME')}}/code/dwm/config.h

# Install tpm and tmux plugins
install-tmux-plugins:
    @if [ ! -d "{{env_var('HOME')}}/.config/tmux/plugins/tpm" ]; then \
        git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm; \
    fi
    ~/.config/tmux/plugins/tpm/bin/install_plugins

# Deploy PipeWire configuration for different hosts
deploy-pipewire:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if [ "{{hostname}}" = "archbook" ]; then \
        echo "T460s detected. Deploying T460s PipeWire config...."; \
        yay -S --needed pipewire-pulse wireplumber; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" pipewire-t460s; \
    else \
        echo "Deploying PC PipeWire config...."; \
        yay -S --needed pipewire-pulse wireplumber; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" pipewire-pc; \
    fi
    systemctl --user restart pipewire

# Install irssi (right now only on the server)
install-irssi:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if [ "{{hostname}}" != "brutal" ]; then \
        echo "install-mpd is only for the T460S (archbook)."; \
        exit 1; \
    fi
    sudo pacman -S --needed irssi
    stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" irssi
 
# Install mpd and ncmpcpp for T460S (archbook) with music on SD card
install-mpd:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if [ "{{hostname}}" != "archbook" ]; then \
        echo "install-mpd is only for the T460S (archbook)."; \
        exit 1; \
    fi
    sudo pacman -S --needed mpd mpc ncmpcpp
    stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" mpd
    systemctl --user enable --now mpd
    mpc update
    stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" ncmpcpp

# Deploy keyd and configuration for T460S (archbook) to remap CapsLock+h/j/k/l to arrow keys
deploy-keyd:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if [ "{{hostname}}" != "archbook" ]; then \
        echo "keyd is only for the T460S (archbook)."; \
        exit 1; \
    fi
    sudo pacman -S --needed keyd
    sudo systemctl enable --now keyd
    sudo install -Dm644 {{justfile_directory()}}/keyd/default.conf \
        /etc/keyd/default.conf
    sudo systemctl restart keyd
    sudo install -Dm755 {{justfile_directory()}}/keyd/keyd-resume /lib/systemd/system-sleep/keyd-resume

# Recipe to install TLP for power management on the T460S (archbook)
deploy-tlp:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if [ "{{hostname}}" != "archbook" ]; then \
        echo "TLP is only for the T460S (archbook)."; \
        exit 1; \
    fi
    sudo pacman -S --needed tlp
    sudo install -Dm644 {{justfile_directory()}}/tlp/tlp.conf \
        /etc/tlp.conf
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket power-profiles-daemon.service
    sudo systemctl enable --now tlp

# deploy iwlwifi modprobe config to prevent issues from deep sleep on the T460S (archbook)
deploy-iwlwifi:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if [ "{{hostname}}" != "archbook" ]; then \
        echo "iwlwifi modprobe config is only for the T460S (archbook)."; \
        exit 1; \
    fi
    sudo install -Dm644 {{justfile_directory()}}/modprobe/iwlwifi.conf \
        /etc/modprobe.d/iwlwifi.conf

# Recipe to deploy Ghostty configurations
deploy-ghostty:
    @echo "Deploying base Ghostty configuration..."
    stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" ghostty-base

    @if [ "{{os_name}}" = "Darwin" ]; then \
        echo "Detected macOS. Deploying Mac Ghostty overrides..."; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" ghostty-mac; \
    else \
        echo "Detected Linux. Deploying Linux Ghostty overrides..."; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" ghostty-linux; \
    fi

# Remove Ghostty configuration using stow
remove-ghostty:
    @echo "Removing Ghostty configurations..."
    stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" ghostty-base

    @if [ "{{os_name}}" = "Darwin" ]; then \
        stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" ghostty-mac; \
    else \
        stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" ghostty-linux; \
    fi

# Recipe to deploy Alacritty configurations
deploy-alacritty:
    @echo "Deploying base Alacritty configuration..."
    stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" alacritty-base

    @if [ "{{os_name}}" = "Darwin" ]; then \
        echo "Detected macOS. Deploying Mac Alacritty overrides..."; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" alacritty-mac; \
    else \
        echo "Detected Linux. Deploying Linux Alacritty overrides..."; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" alacritty-linux; \
    fi

# Remove Alacritty configuration using stow
remove-alacritty:
    @echo "Removing Alacritty configurations..."
    stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" alacritty-base

    @if [ "{{os_name}}" = "Darwin" ]; then \
        stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" alacritty-mac; \
    else \
        stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" alacritty-linux; \
    fi

deploy-gnupg:
    @echo "Deploying base gnupg config file..."
    stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" gnupg-base

    @if [ "{{os_name}}" = "Darwin" ]; then \
        echo "Detected macOS. Deploying Mac gnupg overrides..."; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" gnupg-mac; \
    else \
        echo "Detected Linux. Deploying Linux gnupg overrides..."; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" gnupg-linux; \
    fi
    @echo "Setting correct permissions..."
    chmod 700 {{env_var('HOME')}}/.gnupg
    find {{env_var('HOME')}}/.gnupg -type d -exec chmod 700 {} \;
    find {{env_var('HOME')}}/.gnupg -type f -exec chmod 600 {} \;

remove-gnupg:
    @echo "Removing gnupg configurations..."
    stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" gnupg-base

    @if [ "{{os_name}}" = "Darwin" ]; then \
        stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" gnupg-mac; \
    else \
        stow -D -d {{justfile_directory()}} -t "{{env_var('HOME')}}" gnupg-linux; \
    fi

# Install and configure mutt mail setup (archbook only)
deploy-mail:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Arch Linux."; \
        exit 1; \
    fi
    @if [ "{{hostname}}" != "archbook" ]; then \
        echo "deploy-mail is only for the T460S (archbook)."; \
        exit 1; \
    fi
    yay -S --needed neomutt msmtp fetchmail procmail urlscan w3m
    stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" mutt
    @for dir in IN.madhatter IN.arvid IN.arvid.warnecke \
                IN.madhatter/DRAFTS IN.madhatter/SENT \
                IN.arvid/DRAFTS IN.arvid/SENT \
                IN.arvid.warnecke/DRAFTS IN.arvid.warnecke/SENT \
                list.vim list.ruby-talk list.hbase-user \
                list.arch-general list.arch-dev-public \
                spam spam-filtered ebay TV-Programm; do \
        mkdir -p "{{env_var('HOME')}}/mail/$$dir"/{cur,new,tmp}; \
    done
    @echo ""
    @echo "Done. Still needed:"
    @echo "  ~/.fetchmailrc  — fill in password"
    @echo "  ~/.msmtprc      — fill in password"

# Deploy systemd-resolved and systemd-networkd DNS/network configuration for Linux
deploy-network-setup:
    @if [ "{{os_name}}" != "Linux" ]; then \
        echo "This recipe is only for Linux."; \
        exit 1; \
    fi
    sudo install -Dm644 {{justfile_directory()}}/network/resolved.conf \
        /etc/systemd/resolved.conf
    sudo install -Dm644 {{justfile_directory()}}/network/25-wireless.network \
        /etc/systemd/network/25-wireless.network
    sudo install -Dm644 {{justfile_directory()}}/network/20-wired.network \
        /etc/systemd/network/20-wired.network
    sudo install -Dm644 {{justfile_directory()}}/network/iwd-main.conf \
        /etc/iwd/main.conf
    sudo systemctl disable --now NetworkManager
    sudo systemctl enable --now systemd-networkd
    sudo systemctl restart systemd-resolved
    sudo systemctl restart iwd

# Full archbook setup - runs all relevant recipes for the T460S
setup-archbook:
  @if [ "{{os_name}}" != "Linux" ]; then \
      echo "This recipe is only for Arch Linux."; \
      exit 1; \
  fi
  just install-arch-setup
  just install-deps
  just install-tmux-plugins
  just deploy-keyd
  just deploy-tlp
  just deploy-iwlwifi
  just deploy-pipewire
  just deploy-network-setup
  just install-mail 
  just install-mpd
  @echo "archbook setup complete."
