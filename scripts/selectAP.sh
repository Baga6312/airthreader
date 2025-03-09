#!/bin/bash 

if [[ $1 == *"mon"* ]]  then 
	airodump-ng --output-format csv -w access_point_list $1  >/dev/null 2>&1 &   
	AIRODUMP_PID=$!
	sleep 7 
	kill -9 $AIRODUMP_PID
else 
	echo " [-] No interface in monitor found"
	exit 1
fi 

LINE_NUMBERS=$(grep -n '^[[:space:]]*$' access_point_list-01.csv | cut -d: -f1 | head -n 2 | tail -1 )

mapfile -t access_points < <(cat access_point_list-01.csv | head -n $LINE_NUMBERS | sed -n "3,${LINE_NUMBERS}p" | cut -d "," -f14 )

mapfile -t mac_address< <(cat access_point_list-01.csv | head -n $LINE_NUMBERS | sed -n "3,${LINE_NUMBERS}p" | cut -d "," -f1 )

printf ' Enter the AP number : \n'

for ((i=0; i<${#access_points[@]}; i++)); do
	if [[ -n  "${access_points[$i]}" ]] then 
		printf " $i) "  
		printf " ${mac_address[$i]} === "
		printf "${access_points[$i]} \n"
	else 
		echo " $i)"  " ${mac_address[$i]} === <Hidden_Network>"
	fi 
done

read -p " : " number  

re='^[0-9]+$'
if ! [[ $number =~ $re ]] ; then
   echo " [-] Not a number" >&2; exit 1
fi 

MAC_AP=${mac_address[$number]}
