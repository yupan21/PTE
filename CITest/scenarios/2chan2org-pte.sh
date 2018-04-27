#!/bin/bash
#
#

testcasename=RMT-channel2org
networkCompose=2chan2org
CISconfigfilename=chan2-2org2chan.json
testcaseconfigfile1='/samplecc/samplecc-chan1-FAB-3808-2i1-TLS.json'
testcaseconfigfile2='/samplecc/samplecc-chan2-FAB-3808-2i1-TLS.json'
HOST1=172.16.50.151
HOST1COMPOSE=machine1-solo-orderer.yml
HOST2=172.16.50.153
HOST2COMPOSE=machine2-solo-org12.yml
# HOST3=172.16.50.151
# HOST3COMPOSE=machine3-solo-org34.yml
# if you change you host compose file, make sure you use nodejs to modify you SCFILEs

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

function getpprof(){
    cd $PROCESS_CPU_DIR
    sleep 200
    go tool pprof -pdf http://$HOST1:6061/debug/pprof/profile?seconds=120 > orderer-$HOST1-pprof.pdf &
    # orderer
    go tool pprof -pdf http://$HOST2:6060/debug/pprof/profile?seconds=120 > peer-$HOST2-pprof.pdf &
    # peer
}

function nodeconfig(){
    node ./config.js $testcasename$testcaseconfigfile1 $1 $2
    node ./config.js $testcasename$testcaseconfigfile2 $1 $2
}

# # -------------------------------------------------------------------
# # -------------------------------------------------------------------

# # start recording ----------------
# cd $PROCESS_CPU_DIR
# ./start_record.sh $HOST1 $HOST2
# # start recording ---------------


# running test-----------------
cd $CISCRIPT_DIR
nodeconfig nProcPerOrg 1
nodeconfig nRequest 10
nodeconfig runDur 0
nodeconfig invokeType Move
# getpprof &
bash ./test_driver.sh -t $testcasename
## ending case ----------------


# # end recording -----------------
# cd $PROCESS_CPU_DIR
# ./end_record.sh $HOST1 $HOST2
# # end recording ---------------