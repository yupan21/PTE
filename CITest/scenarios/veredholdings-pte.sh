#!/bin/bash
#
#

unset http_proxy https_proxy

testcasename='RMT-veredNew'
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
PTE_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE
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

NEWORG_SCRIPTS=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/composeFile/veredholdings/scripts

function addorg(){
    rm -rf $PTE_DIR/composeFile/$networkCompose/crypto-config
    scp -i ~/.ssh/id_rsa -r root@$HOST1:$PTE_DIR/composeFile/$networkCompose/crypto-config $PTE_DIR/composeFile/$networkCompose/
    # start channel -------------
    cd $CISCRIPT_DIR
    bash test_driver.sh -m $testcasename -p -c $chaincode
    # start channel -------------
}
addorg

# # -------------------------------------------------------------------
# # -------------------------------------------------------------------
# # start recording ----------------
# cd $PROCESS_CPU_DIR
# ./start_record.sh $HOST1 $HOST2
# # start recording ---------------

# running test-----------------
# if not specific the json file, config.js will default modify samplecc/samplecc-chan1-FAB-3808-2i1-TLS.json
for n in 1 ; do 
    cd $CISCRIPT_DIR
    node ./config.js $testcasename nProcPerOrg $n
    node ./config.js $testcasename nRequest 100
    node ./config.js $testcasename runDur 0
    node ./config.js $testcasename invokeType Move
    bash ./test_driver.sh -t $testcasename
    ## ending case ----------------
done 


# # end recording -----------------
# cd $PROCESS_CPU_DIR
# ./end_record.sh $HOST1 $HOST2
# # end recording ---------------