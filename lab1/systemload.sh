#! /bin/bash
if [[ $(id -u) -ne 0]]; then 
    echo "user not root "
    exit 1
fi

while true; do 
   load=$(uptime | awk '{print $10}')
   datatime=$(data '+%Y-%m-%d %H:%M:%S')
   echo "$datatime $load">> /var/log/system-load
   sleep 60
done
