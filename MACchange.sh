#!/bin/bash

#check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run by a user with sudo privileges."
    exit 1
fi

#check if macchanger is installed (or not)
if ! command -v macchanger &> /dev/null; then
    echo "Macchanger binary not found. Installing..."
    sudo apt-get update -y && sudo apt-get install macchanger -y
fi

echo "What type of network do you wish to randomize?"
echo " "
echo "#1. eth"
echo "#2. wlan"
echo " "
read input

#list all the available interfaces and get user-input
if [[ $input == 1 ]]; then
    interfaces=$(ip link show | grep eth | awk '{print $2}' | tr -d ':')
    echo "Available Ethernet interfaces: $interfaces"
    read -p "Enter the Ethernet interface you want to randomize: " type_eth

    # Validate interface
    if ! ifconfig $type_eth &> /dev/null; then
        echo "$type_eth not found. Please check the device name."
        exit 1
    fi

    #randomize the MAC address using macchanger
    echo "Randomizing MAC for $type_eth..."
    sudo macchanger -r $type_eth
    echo "Randomized MAC for $type_eth"
    
else
    interfaces=$(ip link show | grep wlan | awk '{print $2}' | tr -d ':')
    echo "Available WLAN interfaces: $interfaces"
    read -p "Enter the WLAN interface you want to randomize: " type_wlan

    #Validate interface
    if ! ifconfig $type_wlan &> /dev/null; then
        echo "$type_wlan not found. Please check the device name."
        exit 1
    fi

    #randomize MAC address using macchanger
    echo "Randomizing MAC for $type_wlan..."
    sudo macchanger -r $type_wlan
    echo "Randomized MAC for $type_wlan"
fi

#check global network connectivity after MAC change (ping to google dns for verif.)
echo "Checking network connectivity..."
if ! ping -c 3 8.8.8.8 &> /dev/null; then
    echo "Network is not reachable after changing MAC address. Check your connection."
else
    echo "Network is reachable."
fi

#offer user to revert to original/previous MAC address
read -p "Would you like to revert to the original MAC address? (y/n): " revert
if [ "$revert" == "y" ]; then
    if [[ $input == 1 ]]; then
        sudo macchanger -p $type_eth
        echo "Original MAC restored for $type_eth."
    else
        sudo macchanger -p $type_wlan
        echo "Original MAC restored for $type_wlan."
    fi
fi

#log the MAC change event to a log file
log_file="/var/log/mac_randomizer.log"
echo "$(date) - Changed MAC for $type_eth/$type_wlan" >> $log_file

echo "Script finished."
