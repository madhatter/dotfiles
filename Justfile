# Determine the operating system and hostname
os_name := `uname -s`
hostname := `command -v hostnamectl > /dev/null 2>&1 && hostnamectl hostname || hostname`

# Define the list of packages to manage with stow
packages := if os_name == "Darwin" { "certs claude fastfetch git mise tmux zsh" } else { "claude fastfetch git mise picom rofi tmux zsh redshift" }

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
        brew install powerlevel10k fzf direnv mise jq oath-toolkit fastfetch alacritty vivid gnupg pinentry-mac; \
    else \
        echo "Installing dependencies via pacman..."; \
        yay -S --needed zsh-theme-powerlevel10k fzf direnv mise jq oath-toolkit fastfetch xclip alacritty vivid rofi rofi-calc papirus-icon-theme picom slock xss-lock gnupg pinentry redshift; \
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
    cd {{env_var('HOME')}}/code/dwm && makepkg -sfi
    rm {{env_var('HOME')}}/code/dwm/config.h

# Install tpm and tmux plugins
install-tmux-plugins:
    @if [ ! -d "{{env_var('HOME')}}/.config/tmux/plugins/tpm" ]; then \
        git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm; \
    fi
    ~/.config/tmux/plugins/tpm/bin/install_plugins

# Deploy PipeWire configuration for different hosts
deploy-pipewire:
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
