#!/bin/bash
export DISPLAY=:0
LOAD=`cat /sys/class/power_supply/BAT0/energy_now`
FULL=`cat /sys/class/power_supply/BAT0/energy_full`
STATUS=`cat /sys/class/power_supply/BAT0/status`
FULL_P=$(($FULL/100))
TOTAL=$(($LOAD / $FULL_P))
if [[ "x$STATUS" == "xDischarging" && $TOTAL -lt 6 ]]; then
	$(notify-send -u critical -t 60000 -a battery "Very low battery warning" "Forcing hibernation now.")
	$(sleep 20)
	$(sudo pm-hibernate)
elif [[ "x$STATUS" == "xDischarging" && $TOTAL -lt 10 ]]; then
	$(notify-send -u critical -t 60000 -a battery "Low battery warning" "Connect to a charger near you.")
fi
#echo $TOTAL
