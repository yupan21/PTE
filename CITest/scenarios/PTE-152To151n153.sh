#!/bin/bash
#
#

HOST1=172.16.50.153
HOST2=172.16.50.151
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

# start recording ----------------
cd $PROCESS_CPU_DIR
./start_record.sh $HOST1 $HOST2
# start recording ---------------

# running test-----------------
cd $CISCRIPT_DIR
node ./config.js RMT-multi nProcPerOrg 30
node ./config.js RMT-multi nRequest 0
node ./config.js RMT-multi runDur 600
node ./config.js RMT-multi invokeType Move
getpprof &
bash ./test_driver.sh -t RMT-multi
## ending case ----------------



# end recording -----------------
cd $PROCESS_CPU_DIR
./end_record.sh $HOST1 $HOST2
# end recording ---------------