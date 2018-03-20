#!/bin/bash
#
#
# Make sure you run this script on local

echo "detaching and kill screen on local..."
screen -X -S local quit 

echo "connecting to remote host..."
ssh root@172.16.50.153 -i ~/.ssh/id_rsa "echo \"detaching and kill screen on host...\"; \
    screen -X -S host quit; \
    cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/; \
    echo \"transport file on to local \"; \
    scp -i ~/.ssh/id_rsa -r pte_$(date +%m%d)_$(uname -n).txt root@172.16.50.151:/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/ "