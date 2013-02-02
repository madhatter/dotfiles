#!/bin/bash
#export BROWSER=firefox
#export DE=openbox
#exec ck-launch-session dbus-launch openbox-session
#exec ck-launch-session dbus-launch wmfs
eval `ssh-agent`
xset fp rehash
#/home/madhatter/.config/wmfs/wmfs_start.sh
#exec dbus-launch awesome
/home/madhatter/bin/dwm_start.sh
