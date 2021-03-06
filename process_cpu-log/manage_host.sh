#!/bin/bash
#
#
# Make sure you run this script on local

HOST=$1

cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/

echo "removing all exits record..."
DIRNAME=$(date '+%Y-%m-%d-%H-%M-%S')
mkdir $DIRNAME
mv -f *.txt ./$DIRNAME
echo "running screen on local to record driver usage..."
screen -dmS local ./record_system_stats.sh

echo "connecting to remote ${HOST} to record driver usage..."
ssh root@$HOST -i ~/.ssh/id_rsa "cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/; \
    echo \"running screen on remote host...\"; \
    rm -rf *.txt ; \
    screen -dmS host ./record_system_stats.sh"
