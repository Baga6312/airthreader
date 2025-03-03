#!/bin/bash 

echo "Changing $1 to monitor mode..."

ifconfig $1 down 
iwconfig $1 mode monitor
ifconfig $1 up  

#check if the interface in monitor mode 

mapfile -t interfaces < <(ip -br link | grep -v -e docker0 -e lo | awk '{print $1}')

for i in ${!interfaces[@]} ; do 

	if [[ "${interfaces[i]}" == "$1" ]]; then
		if [[ ${interfaces[i]}  != *mon* ]] ; then
			echo "error occured , cant change to monitor mode"
			exit 1
		fi 
    	fi
done 
