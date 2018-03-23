#!/bin/bash

cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts

#### Lauch network and synch-up ledger
bash test_driver.sh -n -m RMT-ecs -p -c samplecc

LOCAL=$1

echo "connecting to sut host"
ssh root@${LOCAL} -i ~/.ssh/id_rsa "cd /opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools; rm -rf cryptogen"
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools
scp -i ~/.ssh/id_rsa -r cryptogen root@${LOCAL}:/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools
#### remove PTE log from synch-up ledger run
