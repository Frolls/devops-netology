#!/bin/bash

hosts=("192.168.0.1" "173.194.222.113" "87.250.250.242")
port="80"

echo "~~ $(date) ~~" > log

while ((1==1)); do
  for host in "${hosts[@]}"; do
    echo "scanning $host:" >> log
      for (( i=1; i <= 5; i++ )); do
        nc -zvw3 "$host" $port
        status=$?
        echo "$i: $status" >> log
        if ((status != 0)); then
          echo "$host" >> error
          echo "Host $host not available. Exiting.."
          exit 1
        fi
      done
  done
done

exit 0



