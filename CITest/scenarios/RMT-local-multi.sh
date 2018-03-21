#!/bin/bash
#
#
# usage sample:
# 
# loading cpu moniting
# chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
# bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh


# loading cpu moniting
chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh


# start network ---
echo "connecting to client host ans startup the network "
ssh root@172.16.50.153 -i ~/.ssh/id_rsa "cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto; \
    cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
    bash RMT-network-multi.sh"
echo "sleeping 6 sec"
sleep 6
## ending case ---


# running test-----------------
# reconfig pte
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto/samplecc
node ./config.js nProcPerOrg 5
# running test
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
bash ./test_driver.sh -t RMT-multi
## ending case ----------------


chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh

# caculate cpu log
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
python client-main.py /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs