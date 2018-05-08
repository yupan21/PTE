#!/bin/bash
#

echo
echo "========= Getting bosc on to your first network ========= "
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
: ${CHANNEL_NAME:="golden-ticket"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/orderer.veredholdings.com/orderers/orderer0.orderer.veredholdings.com/msp/tlscacerts/tlsca.orderer.veredholdings.com-cert.pem

# import utils
. scripts/utils.sh

echo "Fetching channel config block from orderer..."
set -x
setOrdererGlobals
setGlobals 0 4
peer channel fetch 0 $CHANNEL_NAME.block -o orderer0.orderer.veredholdings.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA >&log.txt
res=$?
set +x
cat log.txt
verifyResult $res "Fetching config block from orderer has Failed"

echo
echo "========= Got bosc onto your network ========= "
echo

exit 0
