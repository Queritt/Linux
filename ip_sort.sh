#!/bin/bash

# Sorting ip address by ping
# 0.1
# 2022/07/13

echo ""

list=`cat $HOME/ip_list.txt | wc -l`

if [ $list = 0 ]
then
	echo "ip_list.txt is empty"
    exit 1
fi

echo "Start pinging IP..." && sleep 3
echo ""

rm -f $HOME/ip_list.tmp

while read p; do
	ip_address=`echo "$p" | grep -E -o '([0-9]{1,3}[\.]){3}[0-9]{1,3}'`
	if ping -c 2 -w 1 -q $ip_address
	then
		echo $p >> ip_list.tmp
	fi
done <$HOME/ip_list.txt
cp $HOME/ip_list.tmp $HOME/ip_list.txt 2>/dev/null
rm -f $HOME/ip_list.tmp

sort -u $HOME/ip_list.txt > $HOME/ip_list.tmp
cp $HOME/ip_list.tmp $HOME/ip_list.txt 2>/dev/null
rm -f $HOME/ip_list.tmp
list_after=`cat $HOME/ip_list.txt | wc -l`
echo ""
echo "List size before:" $list
echo "List size after:" $list_after
bad_ip=`echo "100 - ($list_after * 100 / $list)" | bc -s`
echo "Bad ip:" $bad_ip%
echo ""
