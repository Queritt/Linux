#!/bin/bash
# VPN Vireguard
# 0.1
# 2022/10/11

MainGate=Server IP

if ping -q -c 5 -I enp0s3 $MainGate
then
    if ! ip a | grep -q "inet 192.168.90"
    then
        sudo wg-quick down wg0
        sudo wg-quick down wg1
        sleep 5
        sudo wg-quick up wg1
    fi
else
    if ! ip a | grep -q "inet 192.168.60"
    then
        sudo wg-quick down wg0
        sudo wg-quick down wg1
        sleep 5
        sudo wg-quick up wg2
    fi
fi
