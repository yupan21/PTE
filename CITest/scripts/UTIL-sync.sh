#!/bin/bash
#
#


HOST1=172.16.50.151
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

cd $CRYPTO_CONFIG_DIR
scp -i ~/.ssh/id_rsa -r cryptogen root:$HOST1:$CRYPTO_CONFIG_DIR
scp -i ~/.ssh/id_rsa -r cryptogen root:$HOST2:$CRYPTO_CONFIG_DIR

cd $NL_DIR
scp -i ~/.ssh/id_rsa -r cryptogen root:$HOST1:$NL_DIR
scp -i ~/.ssh/id_rsa -r cryptogen root:$HOST2:$NL_DIR