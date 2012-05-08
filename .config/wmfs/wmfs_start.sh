#!/bin/bash

feh --bg-scale /home/madhatter/Dropbox/wallpappen/wallpaper-677043.jpg &
urxvtd -q -f -o &
nm-applet --sm-disable &
dropboxd &
#xcompmgr -C -l -O -D1 &
#volumeicon &
#wicd-client -t &
#devilspie &
conky -c ~/.config/wmfs/scripts/conkyrc_top | while true; read line; do wmfs -c status "testbar $line"; done &
conky -c ~/.config/wmfs/scripts/conkyrc_bottom | while true; read line; do wmfs -c status "bottom $line"; done &
xmodmap ~/.Xmodmap &
mpd &
mpdscribble &
exec ck-launch-session dbus-launch wmfs
