for i in {1..3}; do echo "STRONGPASSWORD" | seid keys add MW$i; done | grep  "address:" | awk '{print $2}' >> wallets.txt
