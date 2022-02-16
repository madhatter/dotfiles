#!/usr/bin/bash

notify-send "$(mpc current -f '[%title%]|Now Playing')" \
    "$(mpc current -f '[[%artist%][ - %album%]]|[%file%]')" -i audio-speakers
