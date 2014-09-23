#!/bin/bash

#feh --bg-scale $HOME/Dropbox/wallpappen/wallpaper-677043.jpg &
urxvtd -q -f -o &
nm-applet --sm-disable &
dropbox start &
xmodmap ~/.Xmodmap &
pgrep -u "$EUID" -x mpd || mpd &
pgrep -u "$EUID" -x mpdscribble || mpdscribble &
feh --bg-fill $HOME/wallpaper &
#conky | while read -r; do xsetroot -name "$REPLY"; done &
dwmbar &
wmname LG3D &
exec dbus-launch dwm
