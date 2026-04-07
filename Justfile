# Determine the operating system using a shell command
os_name := `uname -s`

# Define the list of packages to manage with stow
packages := "certs claude git mise tmux zsh"

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
        brew install powerlevel10k fzf direnv mise jq oathtool fastfetch pandoc w3m; \
    else \
        echo "Installing dependencies via pacman..."; \
        sudo pacman -S --needed zsh-theme-powerlevel10k fzf direnv mise jq oath-toolkit fastfetch pandoc w3m xclip; \
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

# Install tpm and tmux plugins
install-tmux-plugins:
    @if [ ! -d "{{env_var('HOME')}}/.config/tmux/plugins/tpm" ]; then \
        git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm; \
    fi
    ~/.config/tmux/plugins/tpm/bin/install_plugins

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
