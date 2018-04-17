#!/bin/bash
#
#


HOST1=120.79.163.88
HOST2=172.16.50.153
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

echo "Make sure your host is running on swarm mode."
echo "Make sure your character is manager."
echo "Make sure you can connect to another using ssh without password."
echo "Make sure all your config file (cryptogen) on each host are all the same."
echo "Make sure your network yaml file have beed prepared."

# config scfiles -------------
function config_scfile() {
    echo "Configing PTE SCfiles"
    cd $CISCRIPT_DIR 
    node ./config_sc.js RMT-config-multi.json orderer.orderer0.url grpcs://$HOST1:5005
    node ./config_sc.js RMT-config-multi.json orderer.orderer1.url grpcs://$HOST1:5006
    node ./config_sc.js RMT-config-multi.json orderer.orderer2.url grpcs://$HOST1:5007

    node ./config_sc.js RMT-config-multi.json org1.ca.url https://$HOST2:7054
    node ./config_sc.js RMT-config-multi.json org1.peer1.requests grpcs://$HOST2:7061
    node ./config_sc.js RMT-config-multi.json org1.peer1.events grpcs://$HOST2:6051
    node ./config_sc.js RMT-config-multi.json org1.peer2.requests grpcs://$HOST2:7062
    node ./config_sc.js RMT-config-multi.json org1.peer2.events grpcs://$HOST2:6052

    node ./config_sc.js RMT-config-multi.json org2.ca.url https://$HOST2:7055
    node ./config_sc.js RMT-config-multi.json org2.peer1.requests grpcs://$HOST2:7063
    node ./config_sc.js RMT-config-multi.json org2.peer1.events grpcs://$HOST2:6053
    node ./config_sc.js RMT-config-multi.json org2.peer2.requests grpcs://$HOST2:7064
    node ./config_sc.js RMT-config-multi.json org2.peer2.events grpcs://$HOST2:6054

    echo "Sending scfile to $HOST1"
    cd $SCFILES_DIR
    scp -i ~/.ssh/id_rsa ./RMT-config-multi.json root@$HOST1:$SCFILES_DIR

    echo "Sending scfile to $HOST2"
    cd $SCFILES_DIR
    scp -i ~/.ssh/id_rsa ./RMT-config-multi.json root@$HOST2:$SCFILES_DIR
}
# config_scfile
# config scfiles -------------

# # -------------------------------------------------------------------
# # -------------------------------------------------------------------

# start recording ----------------
cd $PROCESS_CPU_DIR
./start_record.sh $HOST1 $HOST2
# start recording ---------------

# running test-----------------
cd $CISCRIPT_DIR
node ./config.js RMT-multi nProcPerOrg 1
node ./config.js RMT-multi nRequest 10
node ./config.js RMT-multi runDur 0
node ./config.js RMT-multi ccOpt.payLoadMin 256
node ./config.js RMT-multi ccOpt.payLoadMax 256
node ./config.js RMT-multi invokeType Move
bash ./test_driver.sh -t RMT-multi
## ending case ----------------

# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 5
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Move
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------

# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 10
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Move
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------

# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 15
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Move
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------

# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 20
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Move
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------

# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 30
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Move
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------

# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 1
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------


# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 5
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------


# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 10
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------


# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 20
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------



# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 30
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------



# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 40
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------



# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 60
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------



# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 80
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------



# # running test-----------------
# cd $CISCRIPT_DIR
# node ./config.js RMT-multi nProcPerOrg 100
# node ./config.js RMT-multi nRequest 0
# node ./config.js RMT-multi runDur 600
# node ./config.js RMT-multi ccOpt.payLoadMin 256
# node ./config.js RMT-multi ccOpt.payLoadMax 256
# node ./config.js RMT-multi invokeType Query
# bash ./test_driver.sh -t RMT-multi
# ## ending case ----------------




# end recording -----------------
cd $PROCESS_CPU_DIR
./end_record.sh $HOST1 $HOST2
# end recording ---------------