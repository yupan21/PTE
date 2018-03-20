#!/bin/bash

# loading cpu moniting
chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh

## running a case 
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto/samplecc
node config.js invokeType Move
node config.js nProcPerOrg 1
## nProc has changed to 5

# start network
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
echo "connecting to client host ans startup the network "
ssh root@172.16.50.153 -i ~/.ssh/id_rsa "cd cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
    bash RMT-network-auto.sh"
bash ./test_driver.sh -t RMT-auto
node config.js invokeType Query
node config.js nProcPerOrg 1
bash ./test_driver.sh -t RMT-auto
## ending a case 

chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh