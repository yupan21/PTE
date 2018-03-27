#!/bin/bash
#
# check sample usage in the end of the scripts

LOCAL=172.16.50.151
HOST=172.16.50.153

# loading cpu moniting
chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh $HOST


# start network ---
echo "connecting host and startup the network "
ssh root@${HOST} -i ~/.ssh/id_rsa "cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts; \
    echo \"changing network ...\"; \
    python config-network.py RMT-auto -o 3 -x 2 -r 2 -p 2 -n 1 -t solo -f test -w 0.0.0.0 -S enabled -c 2s -l INFO -B 2000 ;\
    chmod +x ./test_nl.sh; \
    cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
    bash RMT-network-auto.sh"
echo "sleeping 6 sec"
sleep 6
## ending case ---

# running test-----------------
# reconfig pte
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
node ./config.js RMT-auto nProcPerOrg 30
node ./config.js RMT-auto eventOpt.timeout 360000
node ./config.js RMT-auto ccOpt.payLoadMax 256
node ./config.js RMT-auto ccOpt.payLoadMin 256
node ./config.js RMT-auto invokeType Move
bash ./test_driver.sh -t RMT-auto
## ending case ----------------

# # running test-----------------
# # reconfig pte
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# node ./config.js RMT-auto nProcPerOrg 10
# node ./config.js RMT-auto invokeType Query
# bash ./test_driver.sh -t RMT-auto
# ## ending case ----------------

# # running test-----------------
# # reconfig pte
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# node ./config.js RMT-auto nProcPerOrg 20
# node ./config.js RMT-auto invokeType Query
# bash ./test_driver.sh -t RMT-auto
# ## ending case ----------------

# # running test-----------------
# # reconfig pte
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# node ./config.js RMT-auto nProcPerOrg 40
# node ./config.js RMT-auto invokeType Query
# bash ./test_driver.sh -t RMT-auto
# ## ending case ----------------


# # running test-----------------
# # reconfig pte
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# node ./config.js RMT-auto nProcPerOrg 60
# node ./config.js RMT-auto invokeType Query
# bash ./test_driver.sh -t RMT-auto
# ## ending case ----------------


# # running test-----------------
# # reconfig pte
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# node ./config.js RMT-auto nProcPerOrg 80
# node ./config.js RMT-auto invokeType Query
# bash ./test_driver.sh -t RMT-auto
# ## ending case ----------------

# # running test-----------------
# # reconfig pte
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# node ./config.js RMT-auto nProcPerOrg 100
# node ./config.js RMT-auto invokeType Query
# bash ./test_driver.sh -t RMT-auto
# ## ending case ----------------



###########################################################
###########################################################
###########################################################
###########################################################


chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh $LOCAL $HOST

# caculate cpu log
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
python client-main.py /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs


# usage sample:
# 
# loading cpu moniting
# chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
# bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh


# # start network ---
# echo "connecting to client host ans startup the network "
# ssh root@172.16.50.153 -i ~/.ssh/id_rsa "cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto; \
#     echo \"changing network ...\"; \
#     python config-network.py -o 3 -x 2 -r 2 -p 2 -n 1 -t solo -f test -w 0.0.0.0 -S enabled -c 2s -l INFO -B 500 ;\
#     cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
#     bash RMT-network-auto.sh"
# echo "sleeping 6 sec"
# sleep 6
# ## ending case ---


# # start network ---
# echo "connecting to client host ans startup the network "
# ssh root@172.16.50.153 -i ~/.ssh/id_rsa "cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
#     bash RMT-network-auto.sh"
# echo "sleeping 6 sec"
# sleep 6
# ## ending case ---

# # running test-----------------
# # reconfig pte
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto/samplecc
# node ./config.js nProcPerOrg 5
# # running test
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# bash ./test_driver.sh -t RMT-auto
# ## ending case ----------------

# chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
# cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
# bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh

# # caculate cpu log
# cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
# python client-main.py /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs
## ending sample
