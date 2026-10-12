#!/bin/bash
# ssh forward agent
eval `ssh-agent`

eval "$(gpg-agent --daemon)"

# refresh fonts for windowmanager
xset +fp /usr/share/fonts/TTF
xset +fp $HOME/.fonts
xset fp rehash

# no beep
xset -b

# almost disable all TrackPoint features
if [ "$(hostnamectl hostname)" = "archbook" ]; then
    xinput set-prop 11 "libinput Scroll Method Enabled" 0 0 0
    xinput set-prop 11 "libinput Accel Speed" -0.9
fi

# load X resources and pass cursor settings to GTK/Chromium/Steam
xrdb -merge "$HOME/.Xdefaults"
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE="$(xrdb -query | awk '/^Xcursor.size:/ {print $2}')"

#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#eval $(/usr/bin/gnome-keyring-daemon --daemonize --replace --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

export _JAVA_AWT_WM_NONREPARENTING=1

# stop the llm orchestrator if it is running
if systemctl --user is-active --quiet llm-orchestrator.service; then
    systemctl --user stop llm-orchestrator.service
fi

# start the windowmanager
$HOME/bin/dwm_start.sh
