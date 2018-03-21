#!/bin/bash
#
#
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


# loading cpu moniting
chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh

# running test-----------------
# reconfig pte
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto/samplecc
node ./config.js nProcPerOrg 5
# running test
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
bash ./test_driver.sh -t RMT-auto
## ending case ----------------


# running test-----------------
# reconfig pte
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto/samplecc
node ./config.js nProcPerOrg 5
# running test
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
bash ./test_driver.sh -t RMT-auto
## ending case ----------------


# start network ---
echo "connecting to client host ans startup the network "
ssh root@172.16.50.153 -i ~/.ssh/id_rsa "cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto; \
    echo \"changing network ...\"; \
    python config-network.py -o 3 -x 2 -r 2 -p 2 -n 1 -t solo -f test -w 0.0.0.0 -S enabled -c 2s -l INFO -B 500 ;\
    chmod +x ./test_nl.sh; \
    cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
    bash RMT-network-auto.sh"
echo "sleeping 6 sec"
sleep 6
## ending case ---


# running test-----------------
# reconfig pte
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto/samplecc
node ./config.js nProcPerOrg 5
# running test
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
bash ./test_driver.sh -t RMT-auto
## ending case ----------------


# running test-----------------
# reconfig pte
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/RMT-auto/samplecc
node ./config.js nProcPerOrg 5
# running test
cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
bash ./test_driver.sh -t RMT-auto
## ending case ----------------




chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh

# caculate cpu log
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
python client-main.py /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs