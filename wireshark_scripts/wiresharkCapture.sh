#!/bin/bash

if [ $# -lt 2 ]
then
    #Get first WiFi interface
    interface="$(iwconfig | awk '$3 ~ "802.11" {print $1; exit;}')"
    output="captures"
else
    interface=$1
    output=$2
fi

echo "Disabling Network Manager. Manually re-enable Network Manager after script execution"
nmcli networking off

echo "Setting WiFi interface to 'monitor' mode"
sudo iwconfig wlp58s0 mode Monitor
sudo ifconfig wlp58s0 up

echo "Starting capture on ${interface}."
tshark -b filesize:1000 -i ${interface} -I -w $output
