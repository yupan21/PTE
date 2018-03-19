#!/bin/bash

#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

########## CI test ##########

CWD=$PWD
PREFIX="result"   # result log prefix

cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts

#### Lauch network and synch-up ledger
bash test_driver.sh -n -m RMT-3808-2i -p -c samplecc 
#### remove PTE log from synch-up ledger run
# rm -f ../Logs/RMT-3811-2q*.log

# #### execute testcase RMT-3808-2i: 2 threads invokes, golevelDB
# ./test_driver.sh -t RMT-3808-2i
# #### gather TPS from docker containers
# ./get_peerStats.sh -r RMT-3808-2i -p peer0.org1.example.com peer0.org2.example.com -n $PREFIX -o $CWD -v

# #### execute testcase RMT-3811-2q: 2 threads queries, golevelDB
# ./test_driver.sh -t RMT-3811-2q
# #### gather TPS from PTE log
# grep Summary ../Logs/RMT-3811-2q*.log | grep "QUERY" >> $CWD/$PREFIX"_RMT-3808-2i.log"

