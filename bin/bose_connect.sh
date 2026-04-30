#!/bin/bash

# MAC address of the Bose QC35 II
# Found via bluetoothctl devices
MAC="4C:87:5D:CE:18:2E"

# Send notification (requires libnotify/dunst)
notify-send "Bluetooth" "Connecting to Bose QC35 II..."

# Attempt to connect
bluetoothctl connect "$MAC"

if [ $? -eq 0 ]; then
    notify-send "Bluetooth" "Bose QC35 II connected successfully!"
else
    notify-send "Bluetooth" "Failed to connect to Bose QC35 II"
fi
