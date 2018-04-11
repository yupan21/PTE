#!/bin/bash
#
#

LOCAL=39.108.167.205 # your pte running machine
HOST=120.79.163.88 # your network running machine

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
LOGS_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs





# # start network ---
# echo "connecting host and startup the network "
# ssh root@${HOST} -i ~/.ssh/id_rsa "cd $CISCRIPT_DIR; \
#     echo \"changing network ...\"; \
#     python config-network.py RMT-ecs -o 3 -x 2 -r 2 -p 2 -k 1 -z 1 -n 1 -t kafka -f test -w 0.0.0.0 -S enabled -c 2s -l INFO -B 2000 ;\
#     chmod +x ./test_nl.sh; \
#     cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
#     bash RMT-network-ecs2.sh ${LOCAL}"
# ## ending case ---


# loading moniting
cd $PROCESS_CPU_DIR
./manage_host.sh $HOST


# running test-----------------
# reconfig pte
cd $CISCRIPT_DIR
node ./config.js RMT-ecs nProcPerOrg 1
node ./config.js RMT-ecs nRequest 10
node ./config.js RMT-ecs runDur 0
node ./config.js RMT-ecs ccOpt.payLoadMin 256
node ./config.js RMT-ecs ccOpt.payLoadMax 256
node ./config.js RMT-ecs invokeType Move
bash ./test_driver.sh -t RMT-ecs
## ending case ----------------


# calculate and reciving cpu records 
cd $PROCESS_CPU_DIR
bash ./calculate.sh $HOST
python client-main.py $LOGS_DIR