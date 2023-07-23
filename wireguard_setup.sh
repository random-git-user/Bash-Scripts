#!/bin/bash

#### Script to setup wireguard on a linux machine.

#### Color Codes
RED="\e[31m"
GREEN="\e[32m"
NOCOLOR="\e[0m"

#### Setting up Constants
ub='Ubuntu'
cent='CentOS'
wgd='wireguard'
keys_location='~/.config/wireguard_keys'
wgd_config='/etc/wireguard/wg0.conf'

#### Below three lines will log the output to a wireguard_log.out-$date file where $date is the time stamp

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>wireguard_log.out-$(date +"%H_%M_%S-%d_%m_%Y") 2>&1

#### TODO

## Complete function Public IP
## Complete function Public interface



#### Checking OS version
check_OS () {
	OS_type=$(cat /etc/os-release | head -1 | awk '{print $1}' | awk -F\" '{print $2}')
#	kernel_version=$(uname -r | awk -F\. '{print $1}')
}

#### Checking if wireguard is installed or not
check_wireguard () {
	if [[ $OS_type == $ub ]]; then
		wireguard_status=$(dpkg -s $wgd | grep Status )
		if [[ $wireguard_status == "install ok installed" ]] then
			echo -e "\nWireguard is already installed. Proceeding with configuration..."
		else
			echo -e "\n Installing wireguard..."
			sudo apt install wireguard -y
		fi
	elif [[ $OS_type == $cent ]]; then
		unset wireguard_status
		wireguard_status=$(rpm -qa | grep $wgd | awk -F \- '{print $1}')
		if [[ $wireguard_status == $wgd ]] then
			echo -e "\nWireguard is already installed. Proceeding with configuration..."
		else
			echo -e "\n Installing wireguard..."
			sudo yum install wireguard -y
		fi
	fi
}

#### Check keys directory
keys_dir () {
	if [ -d $keys_location ]; then
		echo -e "\nBacking up any old keys and creating new ones..."
		mv $keys_location $keys_location_$(date +"%H_%M_%S-%d_%m_%Y")
		mkdir -P $keys_location
	else
		echo -e "\nCreating keys directory..."
		mkdir -P $keys_location
	fi
}

#### Create private and public key
create_key () {
	wg genkey | tee $keys_location/private.key | wg pubkey > $keys_location/public.key
}

#### Find Public IP and interface
pub_IP () {
	$public_IP=$(hostname -I)
	$public_interface=$()

}

#### Configuring wireguard Server
config_server () {
	if [ -z $wgd_config ]; then
		echo -e "\nBacking up old wireguard configuration file " ${RED} FOR SERVER ${NOCOLOR}" and creating new one..."
		mv $wgd_config $wgd_config.$(date +"%H_%M_%S-%d_%m_%Y")
	else
		echo -e "\nCreating wireguard configuration file as " ${RED} FOR SERVER ${NOCOLOR} " /etc/wireguard/wg0.conf..."
		touch $wgd_config
	fi
		[Interface] >> $wgd_config
		PrivateKey=$(cat $keys_location/private.key) >> $wgd_config 		## Here comes the private key of wireguard SERVER
		Address=$server_ip/24 >> $wgd_config
		SaveConfig=true >> $wgd_config
		PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $public_interface -j MASQUERADE; >> $wgd_config
		PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $public_interface -j MASQUERADE; >> $wgd_config
		ListenPort = 51820 >> $wgd_config 					## 51820 is the default port
}

#### Configuring wireguard Client
config_client () {
	if [ -z $wgd_config ]; then
		echo -e "\nBacking up old wireguard configuration file " ${GREEN} FOR CLIENT ${NOCOLOR} " and creating new one..."
		mv $wgd_config $wgd_config.$(date +"%H_%M_%S-%d_%m_%Y")
	else
		echo -e "\nCreating wireguard configuration file " ${GREEN} FOR CLIENT ${NOCOLOR} " as /etc/wireguard/wg0.conf..."
		touch $wgd_config
	fi
		[Interface] >> $wgd_config
		PrivateKey=$(cat $keys_location/private.key) >> $wgd_config 		## Here comes the private key of wireguard CLIENT
		Address=$client_ip/24 >> $wgd_config
		SaveConfig=true >> $wgd_config
		[Peer] >> $wgd_config
		PublicKey = $server_public_key >> $wgd_config 				## Here comes the public key of the wireguard SERVER
		Endpoint = $server_IP:51820 >> $wgd_config				## Here comes the PUBLIC IP of the wireguard SERVER with default port 51820
		AllowedIPs = 0.0.0.0/0 >> $wgd_config 	

	
		echo -e "\nKindly contact your system administrator to run the following command: "
		echo -e "\nwg set wg0 peer ${GREEN} $(cat $key_location/public.key) ${NOCOLOR} allowed-ips ${GREEN} $client_IP/32 ${NOCOLOR} "

}


#### Enabling wg0 interface
enab_iface_server () {
	wg-quick up wg0
}

