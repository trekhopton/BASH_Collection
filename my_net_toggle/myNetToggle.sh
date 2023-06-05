#!/bin/bash
# This is a very crude script for toggling static ethernet port configuration.
defaultSubnet=0
defaultHost=15
if [ $# == 0 ]; then
	subnet=$defaultSubnet
	host=$defaultHost
elif [ $# == 1 ]; then
	subnet=$1
	host=$defaultHost
elif [ $# == 2 ]; then
	subnet=$1
	host=$2
else
	printf "incorrect number of arguments provided, provide 0 for defaults, 1 for custom subnet, 2 for custom subnet and host\n"
	exit 1
fi
if cat /etc/network/interfaces | grep -q enp20s0; then
	printf "current enp20s0 config: \n\n"
        cat /etc/network/interfaces
        read -r -p "Are you sure you want to remove enp20s0 config and restart networking? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                sed -i '/enp20s0/,$d' /etc/network/interfaces
        	service networking stop
		ip addr flush dev wlp22s0 
		ip addr flush dev enp20s0
		service networking start
	else
                printf "\naborted\n"
        fi

else
	printf "no current enp20s0 config found: \n\n"
        cat /etc/network/interfaces
        read -r -p "Are you sure you want to append enp20s0 config and restart networking? [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
                printf "auto enp20s0\niface enp20s0 inet static\n\taddress 192.168.$subnet.$host\n\tnetmask 255.255.255.0\n\tgateway 192.168.$subnet.1\n" >> /etc/network/interfaces
		service networking stop
		ip addr flush dev wlp22s0 
                ip addr flush dev enp20s0
                service networking start
		printf "/etc/network/interfaces is now:\n"
		cat /etc/network/interfaces
        else
                printf "\naborted\n"
        fi
fi
exit 0
