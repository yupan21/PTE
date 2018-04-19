#!/bin/bash


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
# bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh

function config_scfile() {
    cd $CISCRIPT_DIR 
    node ./config_sc.js RMT-config-153.json orderer.orderer0.url grpcs://localhost:5005
    # node ./config_sc.js RMT-config-153.json orderer.orderer1.url grpcs://localhost:4789
    # node ./config_sc.js RMT-config-153.json orderer.orderer2.url grpcs://localhost:7946

    node ./config_sc.js RMT-config-153.json org1.ca.url https://localhost:7054
    node ./config_sc.js RMT-config-153.json org1.peer1.requests grpcs://localhost:7061
    node ./config_sc.js RMT-config-153.json org1.peer1.events grpcs://localhost:6051
    node ./config_sc.js RMT-config-153.json org1.peer2.requests grpcs://localhost:7062
    node ./config_sc.js RMT-config-153.json org1.peer2.events grpcs://localhost:6052

    node ./config_sc.js RMT-config-153.json org2.ca.url https://localhost:7055
    node ./config_sc.js RMT-config-153.json org2.peer1.requests grpcs://localhost:7063
    node ./config_sc.js RMT-config-153.json org2.peer1.events grpcs://localhost:6053
    node ./config_sc.js RMT-config-153.json org2.peer2.requests grpcs://localhost:7064
    node ./config_sc.js RMT-config-153.json org2.peer2.events grpcs://localhost:6054
}
echo "Configing PTE SCfiles"
config_scfile



# start network ---
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
python config-network.py RMT-auto -o 1 -x 2 -r 2 -p 2 -n 1 -t solo -f test -w 0.0.0.0 -S enabled -c 2s -l INFO -B 2000
chmod +x ./test_nl.sh

cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
bash test_driver.sh -n -m RMT-auto -p -c samplecc
# start network ---

# running test-----------------
# reconfig pte
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
node ./config.js RMT-auto nRequest 1
node ./config.js RMT-auto runDur 0
node ./config.js RMT-auto nProcPerOrg 1
# node ./config.js RMT-auto ccOpt.payLoadMax 256
# node ./config.js RMT-auto ccOpt.payLoadMin 256
node ./config.js RMT-auto invokeType Move
bash ./test_driver.sh -t RMT-auto
## ending case ----------------


###########################################################
###########################################################


# chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
# cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
# bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh

# # caculate cpu log
# cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
# python client-main.py

