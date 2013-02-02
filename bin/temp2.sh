#!/bin/sh
CHARGE_NOW=`cat /sys/class/power_supply/BAT0/energy_now`
CHARGE_FULL=`cat /sys/class/power_supply/BAT0/energy_full`
CHARGE_PERCENT=$(( $CHARGE_NOW * 100 / $CHARGE_FULL ))
echo "Battery status:            `cat /sys/class/power_supply/BAT0/status`"
echo "Charge:                    $CHARGE_NOW / $CHARGE_FULL = $CHARGE_PERCENT%"
for s in `ls /sys/devices/platform/applesmc.*/temp*input`
do
        integer=`cat $s | cut -c1-2`
        fraction=`cat $s | cut -c3-5`
	labelname=${s%input}label
        echo "`cat $labelname`:                      $integer.$fraction °C"
done
for s in `ls /sys/devices/platform/applesmc.*/fan*output`
do
        partial_path=`echo $s | cut -d'_' -f1`
        name=`echo $partial_path | cut -d'/' -f6`
        current=`cat $s`
        min=`cat ${partial_path}_min`
        max=`cat ${partial_path}_max`
        echo "$name:                      $current RPM (range $min - $max)"
done
# assumes hddtemp is running as a daemon on this port
netcat localhost 7634
