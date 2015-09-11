#!/bin/bash
# ssh forward agent
eval `ssh-agent`

# refresh fonts for windowmanager
xset +fp /usr/share/fonts/local
xset +fp $HOME/.fonts
xset fp rehash

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

# reset alsa mixer
sudo alsactl restore

# start the windowmanager
$HOME/bin/dwm_start.sh
