#!/bin/bash
#
#


HOST1=172.16.50.153
HOST1COMPOSE=machine1-kafka-3orderer-1kfka-1zk.yml
HOST2=172.16.50.153
HOST2COMPOSE=machine2-kafka-2peer-1ca.yml
HOST3=120.79.163.88
HOST3COMPOSE=machine3-kafka-2peer-1ca.yml
# if you change you host compose file, make sure you use nodejs to modify you SCFILEs


HOST1_mapping=114.242.193.198
HOST2_mapping=114.242.193.198
HOST3_mapping=114.242.193.198

# HOST1COMPOSE=machine-solo-3orderer.yml
# HOST2COMPOSE=machine-solo-4peer-2ca.yml

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
function config_scfile() {
    cd $CISCRIPT_DIR 
    node ./config_sc.js RMT-config-multi.json orderer.orderer0.url grpcs://$HOST1_mapping:2377
    # node ./config_sc.js RMT-config-multi.json orderer.orderer1.url grpcs://$HOST1:4789
    # node ./config_sc.js RMT-config-multi.json orderer.orderer2.url grpcs://$HOST1:7946

    node ./config_sc.js RMT-config-multi.json org1.ca.url https://$HOST2:7054
    node ./config_sc.js RMT-config-multi.json org1.peer1.requests grpcs://$HOST2_mapping:4789
    node ./config_sc.js RMT-config-multi.json org1.peer1.events grpcs://$HOST2_mapping:7946
    node ./config_sc.js RMT-config-multi.json org1.peer2.requests grpcs://$HOST2:7062
    node ./config_sc.js RMT-config-multi.json org1.peer2.events grpcs://$HOST2:6052

    node ./config_sc.js RMT-config-multi.json org2.ca.url https://$HOST3:7055
    node ./config_sc.js RMT-config-multi.json org2.peer1.requests grpcs://$HOST3:4789
    node ./config_sc.js RMT-config-multi.json org2.peer1.events grpcs://$HOST3:7946
    node ./config_sc.js RMT-config-multi.json org2.peer2.requests grpcs://$HOST3:7064
    node ./config_sc.js RMT-config-multi.json org2.peer2.events grpcs://$HOST3:6054
}
echo "Configing PTE SCfiles"
config_scfile
# config scfiles ----------------

# sendingCI scfiles ----------------
function sendingCI(){
    echo "Sending scfile to $1"
    cd $SCFILES_DIR
    scp -i ~/.ssh/id_rsa ./RMT-config-multi.json root@$1:$SCFILES_DIR
}
sendingCI $HOST1
sendingCI $HOST2
sendingCI $HOST3
# sendingCI scfiles ----------------


# cleanup the network and restart ------------
function clean_network(){
    echo "Connecting to $1 to cleanup the network."
    ssh root@$1 -i ~/.ssh/id_rsa "cd $NL_DIR; \
        ./cleanNetwork.sh example.com; \
        rm -rf /tmp/* "
}
rm -rf /tmp/*
clean_network $HOST1
clean_network $HOST2
clean_network $HOST3
# cleanup the network ------------


function startup_network() {
    echo "Connecting to $1 to startup the network."
    echo "Startup $2"
    ssh root@$1 -i ~/.ssh/id_rsa "cd $NL_DIR/extra_host_compose; \
        docker-compose -f $2 up -d "
}

# startup the network ------------
startup_network $HOST1 $HOST1COMPOSE
startup_network $HOST2 $HOST2COMPOSE
startup_network $HOST3 $HOST3COMPOSE
# startup the network ------------


# start channel -------------
cd $CISCRIPT_DIR
bash test_driver.sh -m RMT-multi -p -c samplecc
# start channel -------------


# # -------------------------------------------------------------------
# # -------------------------------------------------------------------
# # start recording ----------------
# cd $PROCESS_CPU_DIR
# ./start_record.sh $HOST1 $HOST2
# # start recording ---------------

# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 1
# node ./config.js RMT-multi nRequest 10
# node ./config.js RMT-multi runDur 0
# # node ./config.js RMT-multi ccOpt.payLoadMin 256
# # node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Move
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------

# # end recording -----------------
# cd $PROCESS_CPU_DIR
# ./end_record.sh $HOST1 $HOST2
# # end recording ---------------