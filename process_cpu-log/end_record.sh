#!/bin/bash
#
#
# Make sure you run this script on local

HOST1=$1
HOST2=$2

PROCESS_CPU_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
cd $PROCESS_CPU_DIR
# end of doing something
# 
# doing calculate.sh function
echo "collecting cpu usage from remote host and local host..."
echo "detaching and kill screen on local..."
screen -X -S local quit 

# kill screen on host
for HOST in $HOST1 $HOST2; do
    echo "detaching and kill screen on ${HOST}..."
    ssh root@${HOST} -i ~/.ssh/id_rsa "screen -X -S host quit"
done

# transport file from host to local
for HOST in $HOST1 $HOST2; do
    echo "transport file from ${HOST} to local " 
    cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/
    scp -i ~/.ssh/id_rsa -r root@${HOST}:${PROCESS_CPU_DIR}/*.txt ./
done 


# get the system record log
cd $PROCESS_CPU_DIR
python client-main.py