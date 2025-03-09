#!/bin/bash 

echo ""
echo "[*] Changing $1 to monitor mode..."
sleep 2

echo ""
echo ""

airmon-ng start $1  >/dev/null 2>&1 &
echo ""

mapfile -t interfaces < <(ip -br link |cut -d " " -f1)

if [[ ! ${interfaces[@]} =~ "$1" ]] then 
	echo "[-] Monitor does not exists"      
fi 
