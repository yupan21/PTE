#!/bin/bash
#
#

LOCAL=39.108.167.205 # your pte running machine
HOST=120.79.163.88 # your network running machine

# loading cpu moniting
chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh $HOST



# start network ---
echo "connecting host and startup the network "
ssh root@${HOST} -i ~/.ssh/id_rsa "cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts; \
    echo \"changing network ...\"; \
    python config-network.py RMT-ecs -o 3 -x 2 -r 2 -p 2 -n 1 -t solo -f test -w 0.0.0.0 -S enabled -c 2s -l INFO -B 500 ;\
    chmod +x ./test_nl.sh; \
    cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
    bash RMT-network-ecs2.sh ${LOCAL}"
echo "sleeping 6 sec"
sleep 6
## ending case ---


# # running test-----------------
# # reconfig pte
# cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
# node ./config.js RMT-ecs nProcPerOrg 1
# node ./config.js RMT-ecs invokeType Move
# bash ./test_driver.sh -t RMT-ecs
# ## ending case ----------------




###########################################################
###########################################################
###########################################################
###########################################################
###########################################################



chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh $HOST

# caculate cpu log
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
python client-main.py /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs