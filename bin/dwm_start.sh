#!/bin/bash

#feh --bg-scale $HOME/Downloads/Portal_Wallpaper_RdQbP0U.jpg &
urxvtd -q -f -o &
pgrep -u "$EUID" -x nm-applet || nm-applet --sm-disable &
dropbox start &
pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdas || mpdas -d &
pgrep -u "$EUID" -x redshift || redshift -l 53.35:10.459 &
feh --bg-scale $HOME/wallpaper/wallhaven-doom.png &
#conky | while read -r; do xsetroot -name "$REPLY"; done &
xmodmap $HOME/.Xmodmap &
dwmbar &
wmname LG3D &
dbus-update-activation-environment --systemd DISPLAY &
echo $PATH > /tmp/path
export _JAVA_AWT_WM_NONREPARENTING=1 &
exec dwm
