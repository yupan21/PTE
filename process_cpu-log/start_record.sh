#!/bin/bash
#
#
# Make sure you run this script on local



HOST1=$1
HOST2=$2

PROCESS_CPU_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
LOGS_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs

cd $PROCESS_CPU_DIR

echo "removing all exits record..."
DIRNAME=$(date '+%Y-%m-%d-%H-%M-%S')
mkdir $DIRNAME
mv -f *.txt ./$DIRNAME
chmod +x ./record_system_stats.sh
echo "running screen on local to record cpu usage..."
screen -dmS local ./record_system_stats.sh

# connect host to record system status
for HOST in $HOST1 $HOST2; do
    echo "connecting to remote ${HOST} to record cpu usage..."
    ssh root@$HOST -i ~/.ssh/id_rsa "cd ${PROCESS_CPU_DIR}; echo \"remove *.txt on ${HOST} and start a screen\"; \
        rm -rf *.txt ; \
        screen -dmS host ./record_system_stats.sh"
done

# may be you could do something below this
# archiving logs to another folder
echo "archiving historical logs to another folder"
cd $LOGS_DIR
cd ..
DIRNAME=$(date '+%Y-%m-%d-%H-%M-%S')
mkdir Logs_$DIRNAME
mv -f Logs/* ./Logs_$DIRNAME