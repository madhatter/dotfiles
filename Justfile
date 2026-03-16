# Determine the operating system using a shell command
os_name := `uname -s`

# Define the list of packages to manage with stow
packages := "certs claude zsh"

# General recipes for managing dotfiles with stow
install: deploy-alacritty
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" {{packages}}

uninstall: remove-alacritty
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" -D {{packages}}

restow: deploy-alacritty
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" -R {{packages}}

test:
    stow -nv -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" {{packages}}

# Recipe to deploy Alacritty configurations
deploy-alacritty:
	@echo "Deploying base Alacritty configuration..."
	stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" alacritty-base
	
	@if [ "{{os_name}}" = "Darwin" ]; then \
		echo "Detected macOS. Deploying Mac overrides..."; \
		stow -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" alacritty-mac; \
	else \
		echo "Detected Linux. Deploying Linux overrides..."; \
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
