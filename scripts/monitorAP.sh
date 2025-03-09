#!/bin/bash 

if [[ ! -n $1 && ! "$1" =~ "*mon*"  ]] then 
	echo " [-] No interface in monitor mode found"	
	exit 1
fi 

airodump-ng --bssid $2 $1-w monitor_AP --output-format csv >/dev/null 2>&1 &  
AIRDUMP_PID=$!

echo " [*] Waiting to monitor AP (10s)"
sleep 10
kill -9 $AIRODUMP_PID
