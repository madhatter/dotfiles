#!/bin/sh
case $2 in
    BRTUP) brightnessctl set +10% ;;
    BRTDN) brightnessctl set 10%- ;;
esac
