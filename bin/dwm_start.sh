#!/bin/bash

#feh --bg-scale $HOME/Downloads/Portal_Wallpaper_RdQbP0U.jpg &
urxvtd -q -f -o &
pgrep -u "$EUID" -x nm-applet || nm-applet --sm-disable &
dropbox start &
xmodmap ~/.Xmodmap &
pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &
pgrep -u "$EUID" -x redshift || redshift &
feh --bg-fill $HOME/wallpaper &
#conky | while read -r; do xsetroot -name "$REPLY"; done &
dwmbar &
wmname LG3D &
export _JAVA_AWT_WM_NONREPARENTING=1 &
dbus-update-activation-environment --systemd DISPLAY &
echo $PATH > /tmp/path
#exec dbus-launch dwm
exec dwm
