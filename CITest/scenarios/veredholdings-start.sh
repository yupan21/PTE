#!/bin/bash
#
#
unset http_proxy https_proxy

testcasename='RMT-vered'
networkCompose='veredholdings'
CISconfigfilename='veredholdings.json'
fabric_version='x86_64-1.0.6'
support_version='x86_64-0.4.6'
chaincode='assets-mgm'

HOST1=172.16.50.153
HOST1COMPOSE='docker-compose-e2e-couchdb.yaml'
# HOST2=172.16.50.151
# HOST2COMPOSE=machine2-org1.yml
# HOST3=172.16.50.153
# HOST3COMPOSE=machine3-org2.yml

Scenarios_DIR=${PWD}

PROCESS_CPU_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
# directory above is used to process system record
CRYPTO_CONFIG_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools
# use to modify channel material and cryptogen file
CISCRIPT_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# use to handel the whole test driver and test case config
NL_DIR=/opt/go/src/github.com/hyperledger/fabric-test/tools/NL
# launch you network in this directory
SCFILES_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/CISCFiles
# scfile needs for PTE test

# sendingCI scfiles and copy compose files ----------------
function sendingCIcompose(){
    echo "Sending scfile to $1"
    cd $SCFILES_DIR
    scp -i ~/.ssh/id_rsa ./$CISconfigfilename root@$1:$SCFILES_DIR
    echo "Sending docker-compose file to $1"
    cd $NL_DIR
    scp -i ~/.ssh/id_rsa -r $networkCompose root@$1:$NL_DIR
}
echo "Copying file to $NL_DIR"
yes | cp -r ../../composeFile/* $NL_DIR
sendingCIcompose $HOST1
# sendingCIcompose $HOST2
# sendingCIcompose $HOST3
# sendingCI scfiles and copy compose files ----------------


# cleanup the network and restart ------------
function clean_network(){
    echo "Connecting to $1 to cleanup the network."
    ssh root@$1 -i ~/.ssh/id_rsa "cd $NL_DIR; \
        ./cleanNetwork.sh dev; \
        rm -rf /data/ledgers_backup/*; \
        rm -rf /data/couchdbdata/*/*; \
        rm -rf /data/peerdata/*/*; \
        rm -rf /tmp/* "
}
rm -rf /tmp/*
clean_network $HOST1
# clean_network $HOST2
# clean_network $HOST3
# cleanup the network ------------


function startup_network() {
    echo "Connecting to $1 to startup the network."
    echo "Startup $2"
    ssh root@$1 -i ~/.ssh/id_rsa " \
        cd $NL_DIR/$networkCompose; \
        ENABLE_TLS=true SUPPORT_TAG=$support_version IMAGE_TAG=$fabric_version docker-compose -f $2 up -d "
}

# startup the network ------------
startup_network $HOST1 $HOST1COMPOSE
# startup_network $HOST2 $HOST2COMPOSE
# startup_network $HOST3 $HOST3COMPOSE
# startup the network ------------


# start channel -------------
sleep 20
cd $CISCRIPT_DIR
bash test_driver.sh -m $testcasename -p -c $chaincode
# start channel -------------

# # -------------------------------------------------------------------
# # -------------------------------------------------------------------
# # start recording ----------------
# cd $PROCESS_CPU_DIR
# ./start_record.sh $HOST1 $HOST2
# # start recording ---------------

# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js $testcasename nProcPerOrg 1
# node ./config.js $testcasename nRequest 10
# node ./config.js $testcasename runDur 0
# # node ./config.js $testcasename ccOpt.payLoadMin 256
# # node ./config.js $testcasename ccOpt.payLoadMax 256
# node ./config.js $testcasename invokeType Move
# bash ./test_driver.sh -t $testcasename
# ## ending case ----------------

# # end recording -----------------
# cd $PROCESS_CPU_DIR
# ./end_record.sh $HOST1 $HOST2
# # end recording ---------------