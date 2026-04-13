# Determine the operating system and hostname
os_name := `uname -s`
hostname := `hostnamectl hostname`

# Define the list of packages to manage with stow
packages := if os_name == "Darwin" { "certs claude fastfetch git mise tmux zsh" } else { "claude fastfetch git mise tmux zsh" }

# General recipes for managing dotfiles with stow
install: deploy-alacritty
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" {{packages}}

uninstall: remove-alacritty
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" -D {{packages}}

restow: deploy-alacritty
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" -R {{packages}}

test:
    stow -nv -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" {{packages}}

# Install base dependencies (shell tools, prompt, utilities)
install-deps:
    @if [ "{{os_name}}" = "Darwin" ]; then \
        echo "Installing dependencies via Homebrew..."; \
        brew install powerlevel10k fzf direnv mise jq oathtool fastfetch alacritty vivid; \
    else \
        echo "Installing dependencies via pacman..."; \
        yay -S --needed zsh-theme-powerlevel10k fzf direnv mise jq oath-toolkit fastfetch xclip alacritty vivid pipewire-pulse wireplumber; \
    fi

# Install work-related dependencies (AWS, cloud, infra tools)
install-work-deps:
    @if [ "{{os_name}}" = "Darwin" ]; then \
        echo "Installing work dependencies via Homebrew..."; \
        brew install awscli terraform vault; \
        pip3 install aws-sso-util awsume; \
    else \
        echo "Installing work dependencies via pacman/pip..."; \
        sudo pacman -S --needed aws-cli terraform vault; \
        pip3 install aws-sso-util awsume; \
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

# More Arch Linux-only parts: Rofi launcher/picker
install-rofi:
      @if [ "{{os_name}}" != "Linux" ]; then \
          echo "This recipe is only for Arch Linux."; \
          exit 1; \
      fi
      yay -S --needed rofi rofi-calc papirus-icon-theme
      stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" rofi

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
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" pipewire-t460s; \
    else \
        echo "T460s detected. Deploying T460s PipeWire config...."; \
        stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" pipewire-pc; \
    fi
    systemctl --user restart pipewire

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
