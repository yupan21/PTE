#!/bin/bash
#

echo
echo "========= Getting Org3 on to your first network ========= "
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
: ${CHANNEL_NAME:="testorgschannel1"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# import utils
. scripts/utils.sh

echo "Fetching channel config block from orderer..."
set -x
setOrdererGlobals
setGlobals 0 3
peer channel fetch 0 $CHANNEL_NAME.block -o orderer0.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA >&log.txt
res=$?
set +x
cat log.txt
verifyResult $res "Fetching config block from orderer has Failed"

echo
echo "========= Got Org3 halfway onto your network ========= "
echo

exit 0
