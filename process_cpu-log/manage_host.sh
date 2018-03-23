#!/bin/bash
#
#
# Make sure you run this script on local

HOST=$1

cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/

echo "removing all exits record..."
rm -rf *.txt
chmod +x ./record_cpu.sh
echo "running screen on local to record cpu usage..."
screen -dmS local ./record_cpu.sh

echo "connecting to remote host to record cpu usage..."
ssh root@$HOST -i ~/.ssh/id_rsa "cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/; \
    echo \"running screen on remote host...\"; \
    rm -rf *.txt ; \
    chmod +x ./record_cpu.sh; \
    screen -dmS memory ./record_memory.sh ; \
    screen -dmS host ./record_cpu.sh "
