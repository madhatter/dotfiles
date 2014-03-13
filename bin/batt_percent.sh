#!/bin/bash
#LOAD=`cat /sys/class/power_supply/BAT0/energy_now`
LOAD=`cat /sys/class/power_supply/BAT0/charge_now`
#FULL=`cat /sys/class/power_supply/BAT0/energy_full`
FULL=`cat /sys/class/power_supply/BAT0/charge_full`
FULL_P=$(($FULL/100))
echo $(($LOAD))
echo $(($FULL))
echo $(($LOAD / $FULL_P))
