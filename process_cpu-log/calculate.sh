#!/bin/bash
#
#
# Make sure you run this script on local

echo "collecting cpu usage from remote host and local host..."
echo "detaching and kill screen on local..."
screen -X -S local quit 

LOCAL=$1
HOST=$2

echo "connecting to remote host..."
ssh root@${HOST} -i ~/.ssh/id_rsa "echo \"detaching and kill screen on host...\"; \
    screen -X -S host quit; \
    cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/; \
    echo \"waiting system log to be written and transport file on to local \"; \
    sleep 1; \
    scp -i ~/.ssh/id_rsa -r *.txt root@${LOCAL}:/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/ "

echo "running python scripts to get the statistic result..."
# python ./main.py