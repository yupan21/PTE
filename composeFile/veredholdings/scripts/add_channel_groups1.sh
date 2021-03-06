#!/bin/bash
#

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
# export http_proxy=http://172.16.104.145:8118

# import utils
. ./utils.sh


echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
set -x
OUTPUT=config.json 
GODEBUG=netdns=go \
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > "${OUTPUT}"
set +x
# Modify the configuration to append the new org
set -x
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"OrgBoscMSP":.[1]}}}}}' config.json ./bosc.json > modified_config.json
set +x
# Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to bosc_update_in_envelope.pb
createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json bosc_update_in_envelope.pb

# echo
# echo "========= Config transaction to add bosc to network created ===== "
# echo

# echo "Signing config transaction"
# echo
# signConfigtxAsPeerOrg 1 bosc_update_in_envelope.pb

# echo
# echo "========= Submitting transaction from a different peer (peer0.org2) which also signs it ========= "
# echo
# setGlobals 0 2
# set -x
# peer channel update -f bosc_update_in_envelope.pb -c ${CHANNEL_NAME} -o orderer0.orderer.veredholdings.com:7050 --tls --cafile ${ORDERER_CA}
# set +x

# echo
# echo "========= Config transaction to add bosc to network submitted! =========== "
# echo

# exit 0
