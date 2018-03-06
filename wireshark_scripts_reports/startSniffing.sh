#!/bin/bash

# Check if aircrack is installed
which airodump-ng > /dev/null 2>&1
if [$? -ne 0]
then
    echo "aircrack-ng must be installed to execute this script"
    exit 1 
fi

# Disable Network Manager
echo "Disabling Network Manager. Manually re-enable Network Manager after script execution"
nmcli networking off

# Use input arguments or default values
if [ $# -lt 2 ]
then
    #Get first WiFi interface
    interface="$(iwconfig | awk '$3 ~ "802.11" {print $1; exit;}')"
    output="capturedData/captures"
else
    interface=$1
    output=$2
fi

echo "Starting capture on ${interface}."

# Dump wifi sniffing data from all channels into $output in csv format
sudo airodump-ng -b abg -e --write $output --output-format csv $interface
