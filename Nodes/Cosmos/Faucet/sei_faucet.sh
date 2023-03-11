#!/bin/bash

while true
do
  while read -r host
  do
      wallet=${host}
      echo $wallet 
      curl -X POST -d "{\"address\": \"$wallet\", \"coins\": [\"1000000usei\"]}" http://3.22.112.181:8000
      sleep 5
  done < $HOME/wallets.txt
done
