#!/bin/bash
# ssh forward agent
eval `ssh-agent`

# refresh fonts for windowmanager
xset +fp /usr/share/fonts/local
xset +fp /home/madhatter/.fonts
xset fp rehash

# start the windowmanager
/home/madhatter/bin/dwm_start.sh
