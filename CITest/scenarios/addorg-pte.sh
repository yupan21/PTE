#!/bin/bash
#
#
unset http_proxy https_proxy

testcasename='RMT-multi'
networkCompose='addorg'
CISconfigfilename='RMT-config-multi.json'
fabric_version='x86_64-1.1.0'
support_version='x86_64-0.4.6'
chaincode='assets-mgm'

testcaseconfigfile1='/preconfig/samplecc/samplecc-chan1-install1-TLS.json'
testcaseconfigfile2='/preconfig/samplecc/samplecc-chan1-install2-TLS.json'
testcaseconfigfile3='/preconfig/samplecc/samplecc-chan1-instantiate-TLS.json'

HOST1=172.16.50.153
HOST1COMPOSE=machine1-orderer.yml
HOST2=172.16.50.151
HOST2COMPOSE=machine2-org1.yml
HOST3=172.16.50.153
HOST3COMPOSE=machine3-org2.yml

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

# config scfiles -------------
# config scfiles -------------

# # -------------------------------------------------------------------
# # -------------------------------------------------------------------

function getpprof(){
    cd $PROCESS_CPU_DIR
    sleep 200
    go tool pprof -pdf http://$HOST1:6061/debug/pprof/profile?seconds=120 > orderer-$HOST1-pprof.pdf &
    # orderer
    go tool pprof -pdf http://$HOST2:6060/debug/pprof/profile?seconds=120 > peer-$HOST2-pprof.pdf &
    # peer
}

# # start recording ----------------
# cd $PROCESS_CPU_DIR
# ./start_record.sh $HOST1 $HOST2
# # start recording ---------------

for n in 1 5 10 15 20 ; do 

    # running test-----------------
    cd $CISCRIPT_DIR
    node ./config.js $testcasename chaincodeID sample_cc
    node ./config.js $testcasename nProcPerOrg $n
    node ./config.js $testcasename nRequest 0
    node ./config.js $testcasename runDur 600
    node ./config.js $testcasename invokeType Move
    bash ./test_driver.sh -t $testcasename
    ## ending case ----------------


done 



# # end recording -----------------
# cd $PROCESS_CPU_DIR
# ./end_record.sh $HOST1 $HOST2
# # end recording ---------------