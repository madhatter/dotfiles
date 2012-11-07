#!/bin/bash

#feh --bg-scale /home/madhatter/Dropbox/wallpappen/wallpaper-677043.jpg &
urxvtd -q -f -o &
nm-applet --sm-disable &
dropboxd &
xmodmap ~/.Xmodmap &
mpd &
mpdscribble &
#urxvt -e "ssh-add" &
#exec ck-launch-session dbus-launch awesome
exec dbus-launch awesome
