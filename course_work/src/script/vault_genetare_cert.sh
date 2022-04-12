#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root

vault write -format=json pki_int/issue/my-little-role common_name="test.mylittleserver.com" ttl="730h" > /home/vagrant/full.crt

cat /home/vagrant/full.crt | jq -r .data.certificate > /home/vagrant/test.mylittleserver.com.crt
cat /home/vagrant/full.crt | jq -r .data.issuing_ca >> /home/vagrant/test.mylittleserver.com.crt
cat /home/vagrant/full.crt | jq -r .data.private_key > /home/vagrant/test.mylittleserver.com.key

