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
#trayer --edge top --align right --widthtype percent --width 10 --transparent true --alpha 0 --tint 0x000000 --expand true --heighttype pixel --height 14& 
#conky | while read -r; do xsetroot -name "$REPLY" "$(trayer --edge top --align right --widthtype request --transparent true --alpha 0 --tint 0x000000 --expand true --heighttype pixel --height 14)"; done &
conky | while read -r; do xsetroot -name "$REPLY" ; done &
exec dbus-launch dwm
