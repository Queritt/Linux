#!/bin/bash

# ver 0.06
# modified 2022/06/18

#cpu use threshold
cpu_threshold='85'
#mem idle threshold
mem_threshold='256'
#disk use threshold
disk_threshold='2048'

#---tlgrm
tg_sender () {
    # host_name=$(hostname)
    host_ip=$(ip a | grep 'inet.*ppp' | awk '{print $2}' | cut -f 1 -d "/") 
    TOKEN="XXXXXXXXXX:YYYYYYYYYYYYYY_ZZZZZZZZZZZZZZZZZZZZ"
    ID_CHAT="-000000000"
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    THE_MESSAGE="$host_ip:"%0A" $1"
    curl -X POST --silent --output /dev/null $URL -d chat_id=$ID_CHAT -d text="$THE_MESSAGE"
    exit 0
}

#---cpu
cpu_usage () {
    cpu_load () {
        cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $8}'|cut -f 1 -d "."`
        cpu_use=`expr 100 - $cpu_idle` 
    }
    cpu_load
    if [[ $cpu_use -gt $cpu_threshold ]] 
        then
        sleep 10
        cpu_load
        if [[ $cpu_use -gt $cpu_threshold ]] 
            then  
            echo `date +"%b %d %H:%M"` "CPU warning !!! Utilization: $cpu_use%" >> system_stats.log
            tg_sender "CPU warning !!! Utilization: $cpu_use%"
        fi
    fi
}

#---ram
mem_usage () {
    mem_free=$(free -m | grep Mem: | awk '{print $2-$3}')
    if [ $mem_free -lt $mem_threshold ]
        then
        echo `date +"%b %d %H:%M"` "RAM warning !!! Remaining: $mem_free MB" >> system_stats.log
        tg_sender "RAM warning !!! Remaining: $mem_free MB"
    fi
}

#---swap
swap_usage () {
swap_on=$(swapon --show)
    if [ -n "$swap_on" ]
        then
        mem_free=$(free -m | grep Swap: | awk '{print $2-$3}')
        if [ $mem_free -lt $mem_threshold ]
            then
            echo `date +"%b %d %H:%M"` "Swap warning !!! Remaining: $mem_free MB" >> system_stats.log
            tg_sender "Swap warning !!! Remaining: $mem_free MB"
        fi
    fi
}

#---disk
disk_usage () {
    df -m | grep -vE '^Filesystem|tmpfs|cdrom|/dev/loop|udev' | awk '{ print $4 " " $1 }' | while read output;
    do
      usep=$(echo $output | awk '{ print $1}')
      partition=$(echo $output | awk '{ print $2 }' )
      if [ $usep -lt $disk_threshold ] 
          then
          echo `date +"%b %d %H:%M"` "Disk warning !!! $partition (remaining: $usep MB)" >> system_stats.log
          tg_sender "Disk warning !!! $partition (remaining: $usep MB)"
      fi
    done
}

cpu_usage
mem_usage
swap_usage
disk_usage
