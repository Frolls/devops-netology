#!/bin/bash

echo "task2.sh started"

while ((1==1)); do
  curl -s https://localhost:4757
  if (($? != 0)); then
    date >> curl.log
  else
    echo "Server up! Clean log.."
    truncate -s 0 curl.log
    exit 0
  fi
done