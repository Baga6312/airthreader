#!/bin/bash 

## this is a minimal script for checking dependencies 

dependencies=("curl" "wget" "nmap")

os=$(hostnamectl | grep "Operating System:" | cut -d " " -f3) || $(cat /etc/os-release | head -n 1 | cut -d "=" -f2 | cut -d "\"" -f2 | cut -d " " -f1)  

echo "installing missing dependencies on $os Linux\n" 

	if [[ $os ]]  then  
		case $os in 
			'Arch')
				pacman -S --noconfirm ${dependencies[@]} || yay -S --noconfirm ${dependencies[@]}
				;; 
			'Ubuntu' | 'Debian')
				apt install -y${dependencies[@]}
				;;
			'fedora')
				dnf install -y ${dependencies[@]}
				;;
			*) 
				echo "Distribution not supported\n" 
				;; 
		esac 
	fi 
