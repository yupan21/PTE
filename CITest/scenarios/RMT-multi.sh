#!/bin/bash
#
#
# usage sample:

HOST1=120.79.163.88
HOST2=39.108.167.205
PROCESS_CPU_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
# directory above is used to process system record
CRYPTO_CONFIG_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools
# use to modify channel material and cryptogen file
CISCRIPT_DIR=$GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# use to handel the whole test driver and test case config
NL_DIR=/opt/go/src/github.com/hyperledger/fabric-test/tools/NL
# launch you network in this directory

echo "Make sure you running this script on swarm mode."
echo "Make sure you character is manager."
echo "Make sure you can connect to another using ssh without password"


# transport material file ---
# HOST=39.108.167.205
# echo "remove local crypto-config file"
# cd $CRYPTO_CONFIG_DIR
# rm -rf ./cryptogen
# echo "scp cryptogen file from ${HOST}"
# scp -i ~/.ssh/id_rsa -r root@${HOST}:$CRYPTO_CONFIG_DIR/cryptogen ./
# sleep 5
# transport material file ---

# # start chennel
# echo "start channel---"
# cd $CISCRIPT_DIR
# bash test_driver.sh -m RMT-multi -p -c samplecc
# ## ending start channel ---


# start recording ----------------
cd $PROCESS_CPU_DIR
./start_record.sh $HOST1 $HOST2
# start recording ---------------

# running test-----------------
cd $CISCRIPT_DIR
node ./config.js RMT-multi nProcPerOrg 1
node ./config.js RMT-multi nRequest 0
node ./config.js RMT-multi runDur 600
node ./config.js RMT-multi invokeType Move
bash ./test_driver.sh -t RMT-multi
## ending case ----------------

# end recording -----------------
cd $PROCESS_CPU_DIR
./end_record.sh $HOST1 $HOST2
# end recording ---------------