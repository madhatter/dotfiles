#!/bin/bash
# ssh forward agent
eval `ssh-agent`

# refresh fonts for windowmanager
xset +fp /usr/share/fonts/local
xset +fp $HOME/.fonts
xset fp rehash

# start the windowmanager
$HOME/bin/dwm_start.sh
