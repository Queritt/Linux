#!/bin/bash

# Massa server failover
# ver 0.7
# 2022/07/12

host_ip=192.168.88.50
server_ip=192.168.88.30
wol_ip=192.168.83.255
host_mac=MAC

handle() {
    if ! ping -c 2 $host_ip
    then
        TOKEN="XXXX:YYY_ZZZ"
        ID_CHAT="-XXXX"
        URL="https://api.telegram.org/bot$TOKEN/sendMessage"
        THE_MESSAGE="TM-Massa Failed and HM Started"
        curl -X POST --silent --output /dev/null $URL -d chat_id=$ID_CHAT -d text="$THE_MESSAGE"
	# wakeonlan -i $wol_ip $host_mac
        exit 0   
    fi
}

if ping -c 2 $server_ip
then
    if sudo systemctl status massad | grep -q "Active: active"
    then
       sudo systemctl stop rollwatcherd massad
    fi
else
    if sudo systemctl status massad | grep -q "Active: inactive"
    then
       sudo systemctl start rollwatcherd massad
    else
        if [ `journalctl -u massad.service -n15 | grep "failed" | wc -l` -ge 5 ] 
        then
            handle
        #else
            #if [ `journalctl -u massad.service -n10 | grep "An error" | wc -l` -ge 5 ] 
            #then
                #handle
            #fi
        fi
    fi
fi
