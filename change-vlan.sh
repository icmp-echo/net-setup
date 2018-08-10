#!/bin/bash

#---------------My Notes----------------#
#                                       #
#	Hiddenmem codes:		#
#					#
#	2=Tagged			#
#	3=empty				#
#	1=untagged			#
#					#
#-----------DONT REMOVE THIS -----------#


curl -s  http://"${1}"/login.cgi --data password=password --cookie-jar /etc/ansible/expect-scripts/scratch/netgearcookie$1$2  >/dev/null

hash="$(curl -s --cookie /etc/ansible/expect-scripts/scratch/netgearcookie$1$2 http://"${1}"/switch_info.cgi | grep hash | grep -o '[0-9]*')"

curl -s  --cookie /etc/ansible/expect-scripts/scratch/netgearcookie$1$2  http://"${1}"/8021qMembe.cgi --data  VLAN_ID=$2 --data hash=$hash --data hiddenMem=11111 >/dev/null

curl -s  --cookie /etc/ansible/expect-scripts/scratch/netgearcookie$1$2  http://"${1}"/8021qMembe.cgi --data  VLAN_ID=$2 --data hash=$hash --data hiddenMem=22222 >/dev/null

curl -s  --cookie /etc/ansible/expect-scripts/scratch/netgearcookie$1$2  http://"${1}"/portPVID.cgi --data pvid=$2 --data port3=checked --data port2=checked --data port1=checked  --data hash=$hash >/dev/null

rm /etc/ansible/expect-scripts/scratch/netgearcookie$1$2

echo changed-vlan

exit
