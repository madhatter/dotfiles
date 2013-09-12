#!/bin/bash

#feh --bg-scale /home/madhatter/Dropbox/wallpappen/wallpaper-677043.jpg &
urxvtd -q -f -o &
nm-applet --sm-disable &
dropbox start &
xmodmap ~/.Xmodmap &
mpd &
mpdscribble &
feh --bg-fill .config/awesome/1440x900.png &
conky | while read -r; do xsetroot -name "$REPLY"; done &
exec dbus-launch dwm
