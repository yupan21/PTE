#!/bin/bash
#
#
# Make sure you run this script on local

echo "collecting cpu usage from remote host and local host..."
echo "detaching and kill screen on local..."
screen -X -S local quit 

HOST=$1

echo "connecting to remote host..."
echo "detaching and kill screen on host..."
ssh root@${HOST} -i ~/.ssh/id_rsa "screen -X -S host quit"

echo "waiting system log to be written and transport file on to local " 
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/
scp -i ~/.ssh/id_rsa -r root@${HOST}:/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/*.txt ./