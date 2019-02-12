#!/bin/sh

# get the id from the internal keyboard
remote_id=$(
    xinput list |
    sed -n 's/.*AT\ Translated.*id=\([0-9]*\).*keyboard.*/\1/p'
)
[ "$remote_id" ] || exit

# remap the following keys, only for my custom vintage atari joystick connected
# through an old USB keyboard:
#
# keypad 5 -> keypad 6
# . -> keypad 2
# [ -> keypad 8
# left shift -> left control

mkdir -p /tmp/xkb/symbols
cat >/tmp/xkb/symbols/custom <<\EOF
xkb_symbols "remote" {
    key <CAPS>  { [ MDSW ]       };
    key <AC01> { [ a, A, adiaeresis, Adiaeresis ]       };
};
EOF
