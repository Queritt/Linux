#!/bin/bash

MainGate=HOST

if ping -q -c 5 -I enp0s3 $MainGate
then
    if ! ip a | grep -q "peer 192.168.83.1"
    then
        sudo poff -a
        sleep 5
        sudo pon vpn_1
    fi
else
    if ! ip a | grep -q "peer 192.168.50.1"
    then
        sudo poff -a
        sleep 5
        sudo pon vpn_2
    fi
fi
