#!/bin/bash
echo
CHANNEL_NAME="$1"
DELAY="$2"
GODEBUG=netdns=go
: ${CHANNEL_NAME:="testorgschannel1"}
: ${DELAY:="1"}
: ${LANGUAGE:="golang"}
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export http_proxy=http://172.16.50.151:8118
unset http_proxy https_proxy
CORE_PEER_TLS_ENABLED=true
echo "Channel name : "$CHANNEL_NAME

# import utils
. utils.sh

# addCapabilityToChannel <channel_id> <capabilities_group>
# This function pulls the current channel config, modifies it with capabilities
# for the specified group, computes the config update, signs, and submits it.
addCapabilityToChannel() {
        CH_NAME=$1
        GROUP=$2

        setOrdererGlobals

        # Get the current channel config, decode and write it to config.json
        fetchChannelConfig $CH_NAME config.json

        # Modify the correct section of the config based on capabilities group
        if [ $GROUP == "orderer" ]; then
                jq -s '.[0] * {"channel_group":{"groups":{"Orderer": {"values": {"Capabilities": .[1]}}}}}' config.json ./capabilities.json > modified_config.json
        elif [ $GROUP == "channel" ]; then
                jq -s '.[0] * {"channel_group":{"values": {"Capabilities": .[1]}}}' config.json ./capabilities.json > modified_config.json
        elif [ $GROUP == "application" ]; then
                jq -s '.[0] * {"channel_group":{"groups":{"Application": {"values": {"Capabilities": .[1]}}}}}' config.json ./capabilities.json > modified_config.json
        fi

        # Create a config updated for this channel based on the differences between config.json and modified_config.json
        # write the output to config_update_in_envelope.pb
        createConfigUpdate "$CH_NAME" config.json modified_config.json config_update_in_envelope.pb

        # Sign, and set the correct identity for submission.
        if [ $CH_NAME != "testchainid" ] ; then
                if [ $GROUP == "orderer" ]; then
                      # Modifying the orderer group requires only the Orderer admin to sign.
                      # Prepare to sign the update as the OrdererOrg.Admin
                      setOrdererGlobals
                elif [ $GROUP == "channel" ]; then
                      # Modifying the channel group requires a majority of application admins and the orderer admin to sign.
                      # Sign with PeerOrg1.Admin
                      signConfigtxAsPeerOrg 1 config_update_in_envelope.pb
                      # Sign with PeerOrg2.Admin
                      signConfigtxAsPeerOrg 2 config_update_in_envelope.pb
                      # Prepare to sign the update as the OrdererOrg.Admin
                      setOrdererGlobals
                elif [ $GROUP == "application" ]; then
                      # Modifying the application group requires a majority of application admins to sign.
                      # Sign with PeerOrg1.Admin
                      signConfigtxAsPeerOrg 1 config_update_in_envelope.pb
                      # Prepare to sign the update as the PeerOrg2.Admin
                      setGlobals 0 2
                fi
        else
               # For the orderer system channel, only the orderer admin needs sign
               # which will be attached during the update
               setOrdererGlobals
        fi

        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
                peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer0.example.com:7050 --cafile $ORDERER_CA
                res=$?
                set +x
        else
                set -x
                peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer0.example.com:7050 --tls true --cafile $ORDERER_CA
                res=$?
                set +x
        fi
        verifyResult $res "Config update for \"$GROUP\" on \"$CH_NAME\" failed"
        echo "===================== Config update for \"$GROUP\" on \"$CH_NAME\" is completed ===================== "

}

# echo "Installing jq"
# apt-get update
# apt-get install -y jq

sleep $DELAY

#Config update for /Channel/Orderer on testchainid
echo "Config update for /Channel/Orderer on testchainid"
addCapabilityToChannel testchainid orderer

sleep $DELAY

#Config update for /Channel on testchainid
echo "Config update for /Channel on testchainid"
addCapabilityToChannel testchainid channel

sleep $DELAY

#Config update for /Channel/Orderer
echo "Config update for /Channel/Orderer on \"$CHANNEL_NAME\""
addCapabilityToChannel $CHANNEL_NAME orderer

sleep $DELAY

#Config update for /Channel/Application
echo "Config update for /Channel/Application on \"$CHANNEL_NAME\""
addCapabilityToChannel $CHANNEL_NAME application

sleep $DELAY

#Config update for /Channel
echo "Config update for /Channel on \"$CHANNEL_NAME\""
addCapabilityToChannel $CHANNEL_NAME channel

echo
echo
exit 0
