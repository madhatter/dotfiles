#!/bin/sh
eval `ssh-agent`
eval "$(gpg-agent --daemon)"

pgrep -u "$EUID" -x mpdas || mpdas -d &
pgrep -u "$EUID" -x agent || /usr/lib/geoclue-2.0/demos/agent &

dbus-run-session sway
