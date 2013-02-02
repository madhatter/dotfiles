#!/bin/bash 

amixer sset 'Master Mono' 90% unmute &> /dev/null
amixer sset 'Master' 90% unmute &> /dev/null
amixer sset 'PCM' 90% unmute &> /dev/null
amixer sset 'Front' 90% unmute &> /dev/null
amixer sset 'Center' 90% unmute &> /dev/null
amixer sset 'Surround' 90% unmute &> /dev/null
amixer sset 'Speaker' 90% unmute &> /dev/null
amixer sset 'Headphone' 90% unmute &> /dev/null
