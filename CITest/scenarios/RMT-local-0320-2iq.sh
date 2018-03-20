#!/bin/bash


chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh

cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts


bash ./test_driver.sh -t RMT-3808-2i-10
bash ./test_driver.sh -t RMT-3811-2q-10
bash ./test_driver.sh -t RMT-3811-2i-20
bash ./test_driver.sh -t RMT-3811-2q-20
bash ./test_driver.sh -t RMT-3811-2i-25
bash ./test_driver.sh -t RMT-3811-2q-40
bash ./test_driver.sh -t RMT-3811-2q-60
bash ./test_driver.sh -t RMT-3811-2i-30
bash ./test_driver.sh -t RMT-3811-2q-80

chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh