#!/bin/bash
#
#
# usage sample:
# 
# loading cpu moniting
# chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
# bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh

PROCESS_CPU_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
CRYPTO_CONFIG_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools


# start channel ---
HOST=39.108.167.205
echo "remove local crypto-config file"
cd $CRYPTO_CONFIG_DIR
rm -rf ./cryptogen
echo "scp cryptogen file from ${HOST}"
scp -i ~/.ssh/id_rsa -r root@${HOST}:$CRYPTO_CONFIG_DIR/cryptogen ./
sleep 5
echo "start channel---"
bash test_driver.sh -m RMT-multi -p -c samplecc
## ending start channel ---



# running test-----------------
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
node ./config.js RMT-multi nProcPerOrg 1
node ./config.js RMT-multi nRequest 10
node ./config.js RMT-multi runDur 0
node ./config.js RMT-multi invokeType Move
bash ./test_driver.sh -t RMT-multi
## ending case ----------------