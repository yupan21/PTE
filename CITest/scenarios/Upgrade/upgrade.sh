# !/bin/bash
# 
# 
ORDERER_CA=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CH_NAME=testorgschannel1
OrdererHost=127.0.0.1
DELAY=2


function setOrdererGlobals() {
        CORE_PEER_LOCALMSPID="OrdererOrg"
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
        CORE_PEER_MSPCONFIGPATH=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp
}

function setGlobals () {
        # replace you env from you compose file
	PEER=$1
	ORG=$2
	if [ $ORG -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="PeerOrg1"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp
		if [ $PEER -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.org1.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.org1.example.com:7051
		fi
	elif [ $ORG -eq 2 ] ; then
		CORE_PEER_LOCALMSPID="PeerOrg2"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp
		if [ $PEER -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.org2.example.com:7051
		else
			CORE_PEER_ADDRESS=peer1.org2.example.com:7051
		fi
        # add more org if you have
	# elif [ $ORG -eq 3 ] ; then
	# 	CORE_PEER_LOCALMSPID="Org3MSP"
	# 	CORE_PEER_TLS_ROOTCERT_FILE=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org3.example.com/tls/ca.crt
	# 	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
	# 	if [ $PEER -eq 0 ]; then
	# 		CORE_PEER_ADDRESS=peer0.org3.example.com:7051
	# 	else
	# 		CORE_PEER_ADDRESS=peer1.org3.example.com:7051
	# 	fi
	else
		echo "================== ERROR !!! ORG Unknown =================="
	fi

	env |grep CORE
}


function fetchChannelConfig(){
    unset http_proxy https_proxy

    setOrdererGlobals
    OUTPUT=config.json

    CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH \
    CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE \
    CORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID \
    peer channel fetch config config_block.pb --orderer $OrdererHost:7050 --ordererTLSHostnameOverride orderer0.example.com -c $CH_NAME --tls --cafile $ORDERER_CA
    
    configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > "${OUTPUT}"

}

# Modify the correct section of the config based on capabilities group

function createConfigUpdate(){
    CHANNEL=$1
    ORIGINAL=$2
    MODIFIED=$3
    OUTPUT=$4

    set -x
    configtxlator proto_encode --input "${ORIGINAL}" --type common.Config > original_config.pb
    configtxlator proto_encode --input "${MODIFIED}" --type common.Config > modified_config.pb
    GODEBUG=netdns=go configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb > config_update.pb
    GODEBUG=netdns=go configtxlator proto_decode --input config_update.pb  --type common.ConfigUpdate > config_update.json
    echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
    GODEBUG=netdns=go configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope > "${OUTPUT}"
    set +x
}

function signConfigtxAsPeerOrg() {
        PEERORG=$1
        TX=$2
        setGlobals 0 $PEERORG
        set -x
        CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH \
        CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE \
        CORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID \
        peer channel signconfigtx -f "${TX}"
        res=$?
        set +x
        echo "sign done."
}

function addCapabilityToChannel() {
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

        set -x
        CORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH \
        CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE \
        CORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID \
        peer channel update -f config_update_in_envelope.pb -c $CH_NAME --orderer $OrdererHost:7050 --ordererTLSHostnameOverride orderer0.example.com --tls true --cafile $ORDERER_CA
        res=$?
        set +x

        # verifyResult $res "Config update for \"$GROUP\" on \"$CH_NAME\" failed"
        # echo "===================== Config update for \"$GROUP\" on \"$CH_NAME\" is completed ===================== "

}
#Config update for /Channel/Orderer on testchainid
echo "Config update for /Channel/Orderer on testchainid"
addCapabilityToChannel testchainid orderer

sleep $DELAY

#Config update for /Channel on testchainid
echo "Config update for /Channel on testchainid"
addCapabilityToChannel testchainid channel

sleep $DELAY

#Config update for /Channel/Orderer
echo "Config update for /Channel/Orderer on \"$CH_NAME\""
addCapabilityToChannel $CH_NAME orderer

sleep $DELAY

#Config update for /Channel/Application
echo "Config update for /Channel/Application on \"$CH_NAME\""
addCapabilityToChannel $CH_NAME application

sleep $DELAY

#Config update for /Channel
echo "Config update for /Channel on \"$CH_NAME\""
addCapabilityToChannel $CH_NAME channel