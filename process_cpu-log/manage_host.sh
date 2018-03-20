#!/bin/bash
#
#
# Make sure you run this script on local
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/
chmod +x ./record_cpu.sh
echo "running screen on local..."
screen -dmS local ./record_cpu.sh

echo "connecting to remote host..."
ssh root@172.16.50.153 -i ~/.ssh/id_rsa "cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/; \
    echo \"running screen on remote host...\"; \
    chmod +x ./record_cpu.sh; \
    screen -dmS host ./record_cpu.sh"
