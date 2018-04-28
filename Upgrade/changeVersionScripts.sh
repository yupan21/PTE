# !/bin/bash
# 
# 

testcasename='RMT-multi'
networkCompose='106110upgrade'

HOST1=172.16.50.153
HOST1COMPOSE=machine1-kafka-3orderer-1kfka-1zk.yml
HOST2=172.16.50.151
HOST2COMPOSE=machine2-kafka-2peer-1ca.yml
HOST3=172.16.50.153
HOST3COMPOSE=machine3-kafka-2peer-1ca.yml
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

function upgradeContainer(){
    HOST=$1
    COMPOSE_FILES=$2
    Container=$3
    ssh root@$1 -i ~/.ssh/id_rsa "cd $NL_DIR/$networkCompose; \
        docker-compose -f $COMPOSE_FILES stop $Container; \
        bash cleanChaincodeimage.sh $Container
        IMAGE_TAG=x86_64-1.1.0 docker-compose -f $COMPOSE_FILES up -d --no-deps $Container; \
        echo 666 "
}
upgradeContainer $HOST1 $HOST1COMPOSE orderer0.example.com
upgradeContainer $HOST2 $HOST2COMPOSE ca0
upgradeContainer $HOST2 $HOST2COMPOSE peer0.org1.example.com
upgradeContainer $HOST2 $HOST2COMPOSE peer1.org1.example.com
upgradeContainer $HOST3 $HOST3COMPOSE ca1
upgradeContainer $HOST3 $HOST3COMPOSE peer0.org2.example.com
upgradeContainer $HOST3 $HOST3COMPOSE peer1.org2.example.com

function startConfigtxlator(){
    HOST=$1
    echo "Starting configtxlatro RESTful API on $HOST"
    ssh root@$1 -i ~/.ssh/id_rsa "configtxlator start"
}
# startConfigtxlator $HOST1

# curl -X POST --data-binary @configuration_block.pb http://172.16.50.153:7059/protolator/decode/common.Block