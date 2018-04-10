#!/bin/bash

cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts

#### Lauch network and synch-up ledger
bash test_driver.sh -n -m RMT-auto -p -c samplecc

echo "connecting to sut host"
ssh root@172.16.50.151 -i ~/.ssh/id_rsa "cd /opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools; rm -rf cryptogen"
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools
scp -i ~/.ssh/id_rsa -r cryptogen root@172.16.50.151:/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools
#### remove PTE log from synch-up ledger run
