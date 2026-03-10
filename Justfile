packages := "claude zsh"

install:
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" {{packages}}

uninstall:
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" -D {{packages}}

restow:
    stow -d {{justfile_directory()}} -t "{{env_var('HOME')}}" -R {{packages}}

test:
    stow -nv -R -d {{justfile_directory()}} -t "{{env_var('HOME')}}" {{packages}}
