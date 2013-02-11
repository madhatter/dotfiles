#!/bin/bash
#export BROWSER=firefox
#export DE=openbox
#exec ck-launch-session dbus-launch openbox-session
#exec ck-launch-session dbus-launch wmfs
eval `ssh-agent`
xset fp rehash
#exec dbus-launch awesome
/home/madhatter/bin/dwm_start.sh
#/home/madhatter/.config/awesome/awesome_start.sh
