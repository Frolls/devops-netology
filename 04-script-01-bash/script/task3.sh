#!/bin/bash

hosts=("192.168.0.1" "173.194.222.113" "87.250.250.242")
port="80"

echo "~~ $(date) ~~" > log

for host in "${hosts[@]}"; do
  echo "scanning $host:" >> log
    for (( i=1; i <= 5; i++ )); do
      nc -zvw3 "$host" $port
      echo "$i: $?" >> log
    done
done

exit 0