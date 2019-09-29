#!/bin/bash
# ssh forward agent
eval `ssh-agent`

eval "$(gpg-agent --daemon)"

# refresh fonts for windowmanager
xset +fp /usr/share/fonts/local
xset +fp $HOME/.fonts
xset fp rehash

# no beep
xset -b

#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#eval $(/usr/bin/gnome-keyring-daemon --daemonize --replace --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

# reset alsa mixer
sudo alsactl restore

(compton -CGb) &
# xcompmgr seems to cause weird distortions on moving text or images
#(xcompmgr -c) &

export _JAVA_AWT_WM_NONREPARENTING=1

# start the windowmanager
$HOME/bin/dwm_start.sh
