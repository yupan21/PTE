# verify the result of the end-to-end test
verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute End-2-End Scenario ==========="
		echo
   		exit 1
	fi
}

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
        CORE_PEER_LOCALMSPID="OrgOrdererMSP"
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/orderer.veredholdings.com/orderers/orderer0.orderer.veredholdings.com/msp/tlscacerts/tlsca.orderer.veredholdings.com-cert.pem
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/orderer.veredholdings.com/users/Admin@orderer.veredholdings.com/msp
}

setGlobals () {
	PEER=$1
	ORG=$2
	if [ $ORG -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="OrgBigtreeMSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/bigtree.veredholdings.com/peers/peer0.bigtree.veredholdings.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/bigtree.veredholdings.com/users/Admin@bigtree.veredholdings.com/msp
		if [ $PEER -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.bigtree.veredholdings.com:7051
		else
			CORE_PEER_ADDRESS=peer1.bigtree.veredholdings.com:7051
		fi
	elif [ $ORG -eq 2 ] ; then
		CORE_PEER_LOCALMSPID="OrgFactoringMSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/factoring.veredholdings.com/peers/peer0.factoring.veredholdings.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/factoring.veredholdings.com/users/Admin@factoring.veredholdings.com/msp
		if [ $PEER -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.factoring.veredholdings.com:7051
		else
			CORE_PEER_ADDRESS=peer1.factoring.veredholdings.com:7051
		fi

	elif [ $ORG -eq 3 ] ; then
		CORE_PEER_LOCALMSPID="OrgBoscMSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/bosc.veredholdings.com/peers/peer0.bosc.veredholdings.com/tls/ca.crt
		CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/bosc.veredholdings.com/users/Admin@bosc.veredholdings.com/msp
		if [ $PEER -eq 0 ]; then
			CORE_PEER_ADDRESS=peer0.bosc.veredholdings.com:7051
		else
			CORE_PEER_ADDRESS=peer1.bosc.veredholdings.com:7051
		fi
	else
		echo "================== ERROR !!! ORG Unknown =================="
	fi

	env |grep CORE
}

# fetchChannelConfig <channel_id> <output_json>
# Writes the current channel config for a given channel to a JSON file
fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=$2

  setOrdererGlobals

  echo "Fetching the most recent configuration block for the channel"
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel fetch config config_block.pb -o orderer0.orderer.veredholdings.com:7050 -c $CHANNEL --cafile $ORDERER_CA
    set +x
  else
    set -x
    peer channel fetch config config_block.pb -o orderer0.orderer.veredholdings.com:7050 -c $CHANNEL --tls --cafile $ORDERER_CA
    set +x
  fi
  cp config_block.pb ./scripts/
  # echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  # set -x
  # GODEBUG=netdns=go configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > "${OUTPUT}"
  # set +x
}

# signConfigtxAsPeerOrg <org> <configtx.pb>
# Set the peerOrg admin of an org and signing the config update
signConfigtxAsPeerOrg() {
        PEERORG=$1
        TX=$2
        setGlobals 0 $PEERORG
        set -x
        peer channel signconfigtx -f "${TX}"
        set +x
}

# createConfigUpdate <channel_id> <original_config.json> <modified_config.json> <output.pb>
# Takes an original and modified config, and produces the config update tx which transitions between the two
createConfigUpdate() {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  GODEBUG=netdns=go configtxlator proto_encode --input "${ORIGINAL}" --type common.Config > original_config.pb
  GODEBUG=netdns=go configtxlator proto_encode --input "${MODIFIED}" --type common.Config > modified_config.pb
  GODEBUG=netdns=go configtxlator compute_update --channel_id "${CHANNEL}" --original original_config.pb --updated modified_config.pb > config_update.pb
  GODEBUG=netdns=go configtxlator proto_decode --input config_update.pb  --type common.ConfigUpdate > config_update.json
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
  GODEBUG=netdns=go configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope > "${OUTPUT}"
  set +x
}
