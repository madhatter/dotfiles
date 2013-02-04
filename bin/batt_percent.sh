#!/bin/bash
LOAD=`cat /sys/class/power_supply/BAT0/energy_now`
FULL=`cat /sys/class/power_supply/BAT0/energy_full`
FULL_P=$(($FULL/100))
echo $(($LOAD / $FULL_P))
