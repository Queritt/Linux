#!/bin/bash

# Massa bootstrap list
# ver 0.3
# modified 2022/07/13 

passwd=PASS

cd $HOME/massa/massa-client/

if grep -q "check if your node is running" <<<"$(./massa-client get_status -p "$passwd")"; then
    exit 1
fi

rm -f $HOME/bootstrap_list.tmp

# Getting input and putput address from wallet
for n in $(./massa-client get_status -p $passwd | grep '^Node.*connection' | awk '{print $3"_"$7}')
do
    var1=${n%_*} 
    var2=${n#*_}
    echo [\"$var2:31245\", \"$var1\"], >> $HOME/bootstrap_list.txt
done
sort -u $HOME/bootstrap_list.txt > $HOME/bootstrap_list.tmp
cp $HOME/bootstrap_list.tmp $HOME/bootstrap_list.txt 
rm -f $HOME/bootstrap_list.tmp

# Removing not available ip
while read p; do
    ip_address=`echo "$p" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
    if nc -vz -w 3 $ip_address 31245 | grep "succeeded"
    then
        echo $p >> $HOME/bootstrap_list.tmp
    fi
done <$HOME/bootstrap_list.txt
if [ -f $HOME/bootstrap_list.tmp ]
then
    cp $HOME/bootstrap_list.tmp $HOME/bootstrap_list.txt
    rm $HOME/bootstrap_list.tmp
fi

# Replacing addreses to config file
config_path="$HOME/massa/massa-node/config/config.toml"
bootstrap_list=`cat $HOME/bootstrap_list.txt | shuf -n50 | awk '{ print "        "$0 }'`
len=`wc -l < "$config_path"`
start=`grep -n bootstrap_list "$config_path" | cut -d: -f1`
end=`grep -n "\[optionnal\] port on which to listen" "$config_path" | cut -d: -f1`
end=$((end-1))
first_part=`sed "${start},${len}d" "$config_path"`
second_part="
    bootstrap_list = [
${bootstrap_list}
    ]
"
third_part=`sed "1,${end}d" "$config_path"`
echo "${first_part}${second_part}${third_part}" > "$config_path"
