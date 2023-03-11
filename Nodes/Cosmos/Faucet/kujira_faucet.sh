#!/bin/bash

rm .kujira/*.address && rm .kujira/MW*
for i in {1..5}
do
  ADDRESS="$(echo "PASSWORD" | kujirad keys add "MW$i" | grep "address:" | awk '{print $2}')"
  echo `/bin/date +"%b %d %H:%M"` "Faucet:" `curl -X POST https://faucet.kujira.app/$ADDRESS` >> faucet.log 
  sleep 5
  echo PASSWORD | kujirad tx bank send "MW$i" DELEGATE_ADDRESS 99000000ukuji --chain-id harpoon-3 --fees 5000ukuji -y 2>/dev/null 
done
rm .kujira/*.address && rm .kujira/MW*
