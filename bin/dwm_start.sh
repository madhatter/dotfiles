#!/bin/bash

# Define constants for display configuration
# Run 'xrandr' in your terminal to find your exact output name
readonly DISPLAY_OUTPUT="DP-4"
readonly DISPLAY_MODE="3840x2160"
readonly DISPLAY_RATE="144"
readonly DISPLAY_DISABLE="HDMI-0"

# Export variables before starting background processes
# Fix blank windows in Java applications on non-reparenting WMs (removed the trailing '&')
export _JAVA_AWT_WM_NONREPARENTING=1

# Update DBus environment for systemd user services
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY

# Enforce 4K resolution and refresh rate
xrandr --output "$DISPLAY_OUTPUT" --mode "$DISPLAY_MODE" --rate "$DISPLAY_RATE" --primary \
         --output "$DISPLAY_DISABLE" --off

# Apply US Macintosh keyboard layout to replicate macOS dead keys behavior
# Right Alt + u, followed by u/o/a will produce ü/ö/ä
setxkbmap -layout us -variant mac

# Trick old Java GUI apps into thinking we use a reparenting WM
wmname LG3D

# Set wallpaper (current is a symlink to the actual wallpaper file, allowing for easy updates without changing this script)
feh --bg-scale "$HOME/wallpaper/current" &

# Start cloud sync
#dropbox start &

# Start music player daemon and scrobbler
#pgrep -u "$EUID" -x mpd || mpd &
#pgrep -u "$EUID" -x mpdas || mpdas -d &

# Start redshift for eye care (Coordinates set to your current location area)
#pgrep -u "$EUID" -x redshift || redshift -l 53.35:10.459 &

# Start listening for usb devices
udiskie --no-notify &

# Start custom status bar
dwmbar &

# Replace the shell with the window manager
exec dwm
