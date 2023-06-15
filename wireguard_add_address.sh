#!/bin/bash
# wireguard_add_list
# 0.01
# 2023/06/15

host_address=$1
config_path="/etc/wireguard/wg.out2.ip.conf"
interface="wg.out2.ip"
current_address=$(grep AllowedIPs $config_path | cut -c 14-)

if [[ ${#host_address} = 0 ]]; then echo "Script requires ip or hostname."; return 0; fi

interface_restart () {
    if ip a | grep -q $1; then
        wg-quick down $1;
        wg-quick up $1;
        echo -e "\n--- Wireguard interface \"$1\" restarted. ---\n";
    fi
}

check_address () {
    if ! [[ "$1" =~ "$2" ]] && ping -c 1 -W 1 -q $2 2>/dev/null; then return 0; else return 1; fi    
}

## ip address case
if [[ "$host_address" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
    if check_address "$current_address" "$host_address"; then
        sed -i -e "s/^AllowedIPs.*$/&, $host_address\/32/" $config_path
        interface_restart $interface
        echo "$host_address - successfully added."
    else
        echo "$host_address - already exists or not warning!"
    fi
    return
fi

## hostname case
dns_list=()
pinged_list=""
print_list=()

if host -t A $host_address | grep -q "NXDOMAIN"; then echo "Host \"$host_address\" not found or not working!"; return; fi

for k in $(host -t A $host_address | awk '{print $4}'); do dns_list+=($k); done;

for ping_address in ${dns_list[@]}; do
    if check_address "$current_address" "$ping_address"; then
        pinged_list="${pinged_list}, ${ping_address}\/32"
        print_list+=($ping_address)
    else
        echo "$ping_address - already exists or not working!"
    fi
done;
if (( "${#pinged_list}" > "7" )); then
    sed -i -e "s/^AllowedIPs.*$/&$pinged_list/" $config_path
    interface_restart $interface
    for n in ${print_list[@]}; do echo "$n - successfully added."; done
fi
