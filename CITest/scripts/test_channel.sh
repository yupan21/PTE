#!/bin/bash

#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

FabricTestDir=/opt/go/src/github.com/hyperledger/fabric-test
SDKDir=$FabricTestDir/fabric-sdk-node

PrecfgDir=$1
echo "[$0] PrecfgDir: $PrecfgDir"
# PTE: create/join channels
CWD=$PWD

cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE

echo "[$0] create channel"
echo " ./pte_driver.sh CITest/$PrecfgDir/preconfig/channels/runCases-chan-create-TLS.txt"

    runCreate=`ls CITest/$PrecfgDir/preconfig/channels/runCases*create*`
    echo "runCreate $runCreate"
    for ri in $runCreate; do
       echo "./pte_driver.sh $ri"
       ./pte_driver.sh $ri
       sleep 6s
    done

echo "[$0] join channel"
echo " ./pte_driver.sh CITest/$PrecfgDir/preconfig/channels/runCases-chan-join-TLS.txt"

    runJoin=`ls CITest/$PrecfgDir/preconfig/channels/runCases*join*`
    echo "runJoin $runJoin"
    for ri in $runJoin; do
       echo "./pte_driver.sh $ri"
       ./pte_driver.sh $ri
       sleep 6s
    done


cd $CWD
echo "[$0] current dir: $PWD"
