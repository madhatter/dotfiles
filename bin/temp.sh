#!/bin/sh
for s in `ls /sys/devices/platform/applesmc.*/temp*`
do
        integer=`cat $s | cut -c1-2`
        fraction=`cat $s | cut -c3-5`
        echo "temperature:               $integer.$fraction °C"
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
for s in `ls /dev/sd?`
do
        hddtemp $s 2>/dev/null
done
