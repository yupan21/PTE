#!/bin/bash
#
#
NL_DIR=/opt/go/src/github.com/hyperledger/fabric-test/tools/NL
CISCRIPT_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
cd $NL_DIR
docker rm -f $(docker ps -aq)
docker-compose -f docker-compose.yml up -d
cd $CISCRIPT_DIR 
bash test_driver.sh -m LOC-dev -p -c samplecc