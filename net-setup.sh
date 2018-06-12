#!/bin/bash

#-----------------------------------------------------------#
#         Author: 	    Ankit Vora    		    #
#					                    #
#         Date:		    5/31/2018   	            #
#         Version:	    0.4                             #
#         Notes:            One Click provisioning	    #
#                           Solution for NetGear GS105PE    #
#-----------------------------------------------------------#


read -p "Enter temp ip of the switch:  " temp

printf " \033[31m %s \n\033[0m" "Checking your device - please wait..."

ping -q -c3 $temp > /dev/null

if [ $? -eq 0 ]
then
        printf " \033[31m %s \n\033[0m"  "Switch is Accessible..!"
else
	printf " \033[31m %s \n\033[0m" "SWITCH IS NOT UP:: Check your IP or Layer1 or make sure switch is up..!"
	exit 1
fi

printf "\n"
printf "\n"
printf "  Follow the prompts and hit 'Enter'\n"
printf "\n"


read -p "Enter Hostname: " hostname

read -p "Enter Nonat Vlan: " nonat

read -p "Enter Subscribed Vlan: " sub

read -p "Enter Unsubscribed Vlan: " unsub

read -p "Enter mgmt Vlan: (AP & GS105 have same mgmt vlan): " mgmt

read -p "Enter wifi Vlan: " wifi

read -p "Enter mgmt ip of the switch: " ip

read -p "Enter subnet: (e.g.255.255.255.0):  " subnet

read -p "Enter gateway: " gateway

printf " \033[31m %s \n\033[0m" "   YOU ENTERED  "

apmgmt=$mgmt
passwd=G3BRVhb2j4

echo "Hostname                      : - $hostname"
echo "No-Nat                        : - $nonat"
echo "Subscribed                    : - $sub"
echo "un-Subscribed                 : - $unsub"
echo "Wifi                          : - $wifi"
echo "mgmt vlan                     : - $mgmt"
echo "AP mgmt vlan                  : - $apmgmt"
echo "IP Address                    : - $ip"
echo "Subnet                        : - $subnet"
echo "gateway                       : - $gateway"

while true
do
  printf "\n"
  read -p "Is this correct (y/n)? " answer

  case $answer in
   [yY]* ) printf " \033[31m %s \n\033[0m" "Collecting cookie"

          curl -s  http://"${temp}"/login.cgi --data password=password --cookie-jar ./netgearcookie  >/dev/null

	  if [ -e netgearcookie ]
	  then
          printf " \033[31m %s \n\033[0m" "Cookie file created."
          else
          printf " \033[31m %s \n\033[0m" "Cannot create cookie file please re-check & try again. - Try rebooting switch or check file permission or contact engineering."
	  exit 1
          fi
	  printf " \033[31m %s \n\033[0m" "Collecting session hash"
          hash="$(curl -s --cookie ./netgearcookie http://"${temp}"/switch_info.cgi | grep hash | grep -o '[0-9]*')"

	  printf " \033[31m %s \n\033[0m" "setting up switch management mode"

          curl -s  --cookie ./netgearcookie  http://"${temp}"/plus_utility.cgi --data hash=$hash --data plusUtility=1  >/dev/null

          printf " \033[31m %s \n\033[0m" "setting up vlans"
          curl -s  --cookie ./netgearcookie  http://"${temp}"/8021qCf.cgi --data hash=$hash --data status=Enable  >/dev/null
          curl -s  --cookie ./netgearcookie  http://"${temp}"/8021qCf.cgi --data hash=$hash --data status=Enable --data ADD_VLANID=$sub --data vlanNum=1 --data ACTION=Add >/dev/null
	  curl -s  --cookie ./netgearcookie  http://"${temp}"/8021qCf.cgi --data hash=$hash --data status=Enable --data ADD_VLANID=$unsub --data vlanNum=2 --data ACTION=Add >/dev/null
	  curl -s  --cookie ./netgearcookie  http://"${temp}"/8021qCf.cgi --data hash=$hash --data status=Enable --data ADD_VLANID=$nonat --data vlanNum=3 --data ACTION=Add >/dev/null
	  curl -s  --cookie ./netgearcookie  http://"${temp}"/8021qCf.cgi --data hash=$hash --data status=Enable --data ADD_VLANID=$mgmt --data vlanNum=4 --data ACTION=Add >/dev/null
	  curl -s  --cookie ./netgearcookie  http://"${temp}"/8021qCf.cgi --data hash=$hash --data status=Enable --data ADD_VLANID=$wifi --data vlanNum=5 --data ACTION=Add >/dev/null

          printf " \033[31m %s \n\033[0m" "setting up loop-detection"

          curl -s  --cookie ./netgearcookie  http://"${temp}"/loop_detection.cgi --data hash=$hash --data loopDetection=1 >/dev/null

          printf " \033[31m %s \n\033[0m" "setting up password"

          curl -s  --cookie ./netgearcookie  http://"${temp}"/user.cgi --data hash=$hash  --data oldPassword=password --data newPassword=$passwd --data reNewPassword=$passwd >/dev/null

	  printf " \033[31m %s \n\033[0m" "Tagging ports"

	  curl -s  --cookie ./netgearcookie  http://"${temp}"/8021qMembe.cgi --data hash=$hash --data VLAN_ID=$unsub --data hiddenMem=11111 >/dev/null
	  curl -s  --cookie ./netgearcookie  http://"${temp}"/8021qMembe.cgi --data hash=$hash --data VLAN_ID=$unsub --data hiddenMem=22222 >/dev/null
          curl -s  --cookie ./netgearcookie  http://"${temp}"/portPVID.cgi   --data hash=$hash --data pvid=$unsub --data port3=checked --data port2=checked --data port1=checked >/dev/null

          printf " \033[31m %s \n\033[0m" "setting up IP-Address & Hostname"

          curl -s -m 5  --cookie ./netgearcookie  http://"${temp}"/switch_info.cgi --data hash=$hash --data switch_name=$hostname --data dhcpMode=0 --data ip_address=$ip --data subnet_mask=$subnet --data gateway_address=$gateway >/dev/null 

	  rm ./netgearcookie

	  printf " \033[31m %s \n\033[0m" "Password stored in keepass."
	  printf " \033[31m %s \n\033[0m" "Your switch is ready go..!"

	  break;;

   [nN]* ) printf "\n"
	   printf " \033[31m %s \n\033[0m" "Re-Run the Script "
	   exit 1;;

   * )     echo "what was that?";;
  esac
done

