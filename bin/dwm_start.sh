#!/bin/bash

#feh --bg-scale /home/madhatter/Dropbox/wallpappen/wallpaper-677043.jpg &
urxvtd -q -f -o &
#nm-applet --sm-disable &
dropboxd &
xmodmap ~/.Xmodmap &
mpd &
mpdscribble &
dunst &
feh --bg-fill .config/awesome/1440x900.png &
conky | while read -r; do xsetroot -name "$REPLY"; done &
exec dbus-launch dwm
