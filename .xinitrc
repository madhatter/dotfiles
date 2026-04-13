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

# overwrite .Xdefaults dpi setting on the laptop
if [ "$(hostnamectl hostname)" = "archbook" ]; then
    xrdb -merge - <<EOF
Xft.dpi: 110
EOF
fi

#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#eval $(/usr/bin/gnome-keyring-daemon --daemonize --replace --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

export _JAVA_AWT_WM_NONREPARENTING=1

# start the windowmanager
$HOME/bin/dwm_start.sh
