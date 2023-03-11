#!/bin/bash
# ver 0.5
# massa episod 16.0
# modified 2022/11/22

passwd=PASS
cd /home/web/massa/massa-client/

#---tlgrm
tg_sender () {
    # host_name=$(hostname)
    local host_ip=$(ip a | grep 'inet 192.168.83.' | awk '{print $2}' | cut -f 1 -d "/")
    local TOKEN="XXXX"
    local ID_CHAT="XXXX"
    local URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    local THE_MESSAGE="$host_ip:"%0A" $1"
    curl -X POST --silent --output /dev/null $URL -d chat_id=$ID_CHAT -d text="$THE_MESSAGE"
    # exit 0
}

handle() {
  local wallet_info=$(./massa-client -j wallet_info -p "$passwd")
  local wallet_address=$(jq -r "[.[]] | .[0].address_info.address // empty" <<<"$wallet_info")
  local candidate_rolls=$(jq -r "[.[]] | .[-1].address_info.candidate_rolls" <<<"$wallet_info")
  local balance=$(jq -r "[.[]] | .[-1].address_info.candidate_balance" <<<"$wallet_info")
  # local roll_count=$(bc -l <<<"$balance/100")
  ./massa-client node_add_staking_secret_keys S1pqPZe1jjXwqTMbY4GwiKX49QawUCbxHp6XnmEGEtUpttzq1wt -p "$passwd"
  if [ "$candidate_rolls" -eq "0" ]; then
    local response=$(./massa-client buy_rolls "$wallet_address" 1 0 -p "$passwd")
    if grep -q 'insuffisant balance' <<<"$response"; then
      echo `/bin/date +"%b %d %H:%M"` "Not enough tokens to buy rolls." >> /home/web/roll_watcher.log
      echo "😔😔😔️ Not enough tokens to buy rolls."
      echo "You have $balance."
    else
      echo `/bin/date +"%b %d %H:%M"` "Done. Bought 1 roll." >> /home/web/roll_watcher.log
      echo "✅✅✅ Done. Bought 1 roll."
    fi
  else
    echo `/bin/date +"%b %d %H:%M"` "Everything is ok." >> /home/web/roll_watcher.log
    echo "👍👍👍 Everything is ok."
  fi
}

while true; do
  echo "⏳⏳⏳ Running the script..."
  if grep -q "check if your node is running" <<<"$(./massa-client get_status -p "$passwd")"; then
  # if grep -q "Error" <<<"$(./massa-client get_status)"; then
    # echo `/bin/date +"%b %d %H:%M"` "Node is not running, restarting..." >> /home/web/roll_watcher.log
    echo `/bin/date +"%b %d %H:%M"` "Node is not running" >> /home/web/roll_watcher.log
    echo "😔😔😔 Node is not running."
    # systemctl stop massad
    if ! ping -c 3 -W 1 192.168.82.53; then 
      wakeonlan -i 192.168.83.255 <MAC>
      tg_sender "Massa is not running. HM starting...!"
    fi
    # systemctl stop rollwatcherd
    # echo "❗️❗️❗️ Restarting..."
  else
    handle
  fi
  echo "💤💤💤 Sleeping for 3 min..."
  sleep 180
done
