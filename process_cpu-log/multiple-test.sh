#!/bin/bash
#
#
# Make sure you run this script on local


HOST1=120.79.163.88
HOST2=39.108.167.205

PROCESS_CPU_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log


# echo "removing all exits record..."
# DIRNAME=$(date '+%Y-%m-%d-%H-%M-%S')
# mkdir $DIRNAME
# mv -f *.txt ./$DIRNAME
# chmod +x ./record_system_stats.sh
# echo "running screen on local to record cpu usage..."
# screen -dmS local ./record_system_stats.sh

# # connect host to record system status
# for HOST in $HOST1 $HOST2; do
#     echo "connecting to remote ${HOST} to record cpu usage..."
#     ssh root@$HOST -i ~/.ssh/id_rsa "cd ${PROCESS_CPU_DIR}; echo \"remove *.txt on ${HOST} and start a screen\"; \
#         rm -rf *.txt ; \
#         screen -dmS host ./record_system_stats.sh"
# done

# may be you could do something below this 

cd $PROCESS_CPU_DIR
./start_record.sh $HOST1 $HOST2

sleep 5

cd $PROCESS_CPU_DIR
./end_record.sh $HOST1 $HOST2

# end of doing something
# 
# doing calculate.sh function

# echo "collecting cpu usage from remote host and local host..."
# echo "detaching and kill screen on local..."
# screen -X -S local quit 

# # kill screen on host
# for HOST in $HOST1 $HOST2; do
#     echo "detaching and kill screen on ${HOST}..."
#     ssh root@${HOST} -i ~/.ssh/id_rsa "screen -X -S host quit"
# done

# # transport file from host to local
# for HOST in $HOST1 $HOST2; do
#     echo "transport file from ${HOST} to local " 
#     cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/
#     scp -i ~/.ssh/id_rsa -r root@${HOST}:${PROCESS_CPU_DIR}/*.txt ./
# done 