#!/bin/bash

curl -s  http://"${1}"/login.cgi --data password=5partan5 --cookie-jar /etc/ansible/expect-scripts/scratch/netgearcookie$1  >/dev/null

hash="$(curl -s --cookie /etc/ansible/expect-scripts/scratch/netgearcookie$1 http://"${1}"/switch_info.cgi | grep hash | grep -o '[0-9]*')"

curl -s -X GET  --cookie /etc/ansible/expect-scripts/scratch/netgearcookie$1  http://"${1}"/portPVID.cgi --data hash=$hash | sed -n '40p'  | grep -o '[0-9]*'

rm /etc/ansible/expect-scripts/scratch/netgearcookie$1

exit
