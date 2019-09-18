#!/bin/bash

#feh --bg-scale $HOME/Downloads/Portal_Wallpaper_RdQbP0U.jpg &
urxvtd -q -f -o &
pgrep -u "$EUID" -x nm-applet || nm-applet --sm-disable &
dropbox start &
pgrep -u "$EUID" -x mpd || mpd &
#pgrep -u "$EUID" -x mpdscribble || mpdscribble &
pgrep -u "$EUID" -x mpdas || mpdas &
pgrep -u "$EUID" -x redshift || redshift -l 53.35:10.459 &
feh --bg-fill $HOME/wallpaper &
#conky | while read -r; do xsetroot -name "$REPLY"; done &
xmodmap $HOME/.Xmodmap &
light-locker &
dwmbar &
wmname LG3D &
dbus-update-activation-environment --systemd DISPLAY &
echo $PATH > /tmp/path
#exec dbus-launch dwm
export _JAVA_AWT_WM_NONREPARENTING=1 &
exec dwm
