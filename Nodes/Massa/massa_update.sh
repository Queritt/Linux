#!/bin/bash

# Massa update
# ver 0.2
 #modified 2022/07/12

# sudo systemctl stop rollwatcherd massad

folder_name=massa_$(date +%y%m%d)

mkdir -p $HOME/massa-backup/$folder_name

cp $HOME/massa/massa-node/config/config.toml $HOME/massa-backup/$folder_name
cp $HOME/massa/massa-node/config/node_privkey.key $HOME/massa-backup/$folder_name
cp $HOME/massa/massa-node/config/staking_keys.json $HOME/massa-backup/$folder_name
cp $HOME/massa/massa-client/wallet.dat $HOME/massa-backup/$folder_name

cp $HOME/*.sh $HOME/massa-backup/$folder_name

rm -rf massa

massa_version=`wget -qO- https://api.github.com/repos/massalabs/massa/releases/latest | jq -r ".tag_name"`; \
wget -qO $HOME/massa.tar.gz "https://github.com/massalabs/massa/releases/download/${massa_version}/massa_${massa_version}_release_linux.tar.gz"; \
tar -xvf $HOME/massa.tar.gz; \
rm -rf $HOME/massa.tar.gz

sudo chmod +x $HOME/massa/massa-node/massa-node $HOME/massa/massa-client/massa-client

cp $HOME/massa-backup/$folder_name/config.toml $HOME/massa/massa-node/config
cp $HOME/massa-backup/$folder_name/node_privkey.key $HOME/massa/massa-node/config
cp $HOME/massa-backup/$folder_name/staking_keys.json $HOME/massa/massa-node/config
cp $HOME/massa-backup/$folder_name/wallet.dat $HOME/massa/massa-client

sudo systemctl restart rollwatcherd massad

journalctl -u massad -f -o cat
