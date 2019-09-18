#!/bin/bash
LOAD=`cat /sys/class/power_supply/BAT0/energy_now`
LOAD2=`cat /sys/class/power_supply/BAT1/energy_now`
#LOAD=`cat /sys/class/power_supply/BAT0/charge_now`
FULL=`cat /sys/class/power_supply/BAT0/energy_full`
FULL2=`cat /sys/class/power_supply/BAT1/energy_full`
#FULL=`cat /sys/class/power_supply/BAT0/charge_full`
SFULL=$(($FULL + $FULL2))
SLOAD=$(($LOAD + $LOAD2))

FULL_P=$(($SFULL/100))
echo $(($SLOAD))
echo $(($SFULL))
echo $(($SLOAD / $FULL_P))
