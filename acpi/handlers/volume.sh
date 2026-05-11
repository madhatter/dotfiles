#!/bin/sh
case $2 in
    VOLUP)  wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    VOLDN)  wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%- ;;
    MUTE)   wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac
