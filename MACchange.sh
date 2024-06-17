#! /bin/bash

echo "What type of network do you wish to randomise?"
echo " "
echo "#1. eth"
echo "#2. wlan"
echo " "
read input

# Check for root privileges
# $EUID is an env variable. Contains the id-value of user currently utilising the script.
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run by an user with sudo privileges (root works but is generally not recommended)."
  exit 1
fi
macchanger_bincheck=`which macchange | grep -o macchange > /dev/null &&  echo 0 || echo 1`
if ["$macchnager_bincheck" -ne 1]; then
  echo "Mac changer binary not detected! Running Automated Installation process..."
  sudo apt-get update -y && sudo apt-get install macchanger | yes
fi

# Checking user input.
if [[ $input == 1 ]]
then
	echo " "
	echo "Enter the ethernet device you want to randomise: (e.g. eth0 [or] eth1 [or] eth2)"
	echo " "
	read type_eth
	
	command1=`ifconfig | grep $type_eth`

	# Checking if the returned output from 'command1' has any info about -
 	# the existence of eth connection. If the string is empty, then user is shown to the basic troubleshoot.
	if [ -z "$command1" ];
	then
	   	echo "No eth0 connection! Failed to randomise MAC of eth0."
		echo " "
		echo "Troubleshooting: "
		echo "1. Please try entering an existing ethernet connection (i.e. check your input)"
		echo "2. Please try checking the connection of ethernet cable to your computer/VM is established."
	else
		# Random mac could be implemented by utilizing env variable $RANDOM
		mac1="00:11:22:33:44:55"

	    	sudo ifconfig $type_eth down
		sudo ifconfig $type_eth hw ether $mac1
		sudo ifconfig $type_eth up
		echo " "
		echo "Changed MAC of $type_eth ."
		echo "Current MAC of $type_eth is: $mac1"
	fi

else
	echo " "
	echo "Enter the wlan/NIC device you want to randomise: (e.g. wlan0 [or] wlan1 [or] wlan2)"
	echo " "
	read type_wlan
	echo " "

	command2=`ifconfig | grep $type_wlan`

 	# The same for this part of else-code. (except it is for wlan interface)
	if [ -z "$command2" ];
	then
   	 	echo "wlan0/NIC Adapter not detected. Failed to randomise MAC of wlan0."
		echo " "
		echo "Troubleshooting: "
		echo "1. Please try entering an existing NIC (i.e. check your input)"
		echo "2. Please try checking the connection of NIC to your computer/VM is established."
		echo " "
	else
		echo "MAC Change (wlan0) status: "
		echo " "
	   	sudo macchanger -r $type_wlan
		echo " "
		echo "Changed MAC of NIC/$type_wlan"
	fi
fi
