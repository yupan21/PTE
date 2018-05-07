#!/bin/bash
#

export FABRIC_CFG_PATH=${PWD}
# FABRIC_CFG_PATH is a path which configtx.yaml and crypto.yaml located
WORKING_PATH=${PWD}
cd $WORKING_PATH
echo "cd $WORKING_PATH"

# the main function to addneworg
function addNewOrg () {
  # generate artifacts if they don't exist
  if [ ! -d "$CRYPTO_CONFIG_DIR/peerOrganizations/bosc.veredholdings.com" ]; then
    generateCerts
    generateChannelArtifacts
    createConfigTx
  fi
  
  cd crypto-config/peerOrganizations/bocs.veredholdings.com/ca
  ca2_keyfile=$(ls *_sk)
  echo "the ca keyfile is $ca2_keyfile"
  cd $WORKING_PATH
  # start bosc peers
  IMAGE_TAG=$fabric_version SUPPORT_TAG=$support_version CA2_SERVER_TLS_KEYFILE=$ca2_keyfile docker-compose -f $COMPOSE_FILE_bosc up -d 2>&1

  # start joing bosc
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start bosc network"
    exit 1
  fi
  echo
  echo "###############################################################"
  echo "############### Have bosc peers join network ##################"
  echo "###############################################################"
  docker exec bosccli ./scripts/step2bosc.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to have bosc peers join network"
    exit 1
  fi
}

# Use the CLI container to create the configuration transaction needed to add
# bosc to the network
function createConfigTx () {
  echo
  echo "###############################################################"
  echo "####### Generate and submit config tx to add bosc #############"
  echo "###############################################################"
  docker exec cli scripts/step1bosc.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to create config tx"
    exit 1
  fi
}


# Generates bosc certs using cryptogen tool
function generateCerts (){
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "###############################################################"
  echo "##### Generate bosc certificates using cryptogen tool #########"
  echo "###############################################################"

  (cd $WORKING_PATH
   set -x
   cryptogen generate --config=./bosc-crypto.yaml
   res=$?
   set +x
   if [ $res -ne 0 ]; then
     echo "Failed to generate certificates..."
     exit 1
   fi
  )
}

# Generate channel configuration transaction
function generateChannelArtifacts() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found. exiting"
    exit 1
  fi
  echo "##########################################################"
  echo "#########  Generating bosc config material ###############"
  echo "##########################################################"
  (cd $WORKING_PATH
   export FABRIC_CFG_PATH=$PWD
   set -x
   configtxgen -printOrg OrgBosc > ./bosc.json
   res=$?
   set +x
   if [ $res -ne 0 ]; then
     echo "Failed to generate bosc config material..."
     exit 1
   fi
  )
  cp -r $WORKING_PATH/crypto-config/ $CRYPTO_CONFIG_DIR
  echo
}

############### running parameters ###############
CLI_TIMEOUT=10
CLI_DELAY=3
CHANNEL_NAME="testorgschannel1"
COMPOSE_FILE_bosc='../bocs.yaml'
LANGUAGE=golang
rm -rf crypto-config/
rm -rf bosc.json
CRYPTO_CONFIG_DIR='/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/composeFile/veredholdings/crypto-config'
fabric_version='x86_64-1.0.6'
support_version='x86_64-0.4.6'
echo "start adding new org"
addNewOrg

echo "done."