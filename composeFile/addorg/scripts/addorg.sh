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
  if [ ! -d "$CRYPTO_CONFIG_DIR/cryptogen/crypto-config/peerOrganizations/org3.example.com" ]; then
    generateCerts
    generateChannelArtifacts
    createConfigTx
  fi
  
  cd crypto-config/peerOrganizations/org3.example.com/ca
  ca2_keyfile=$(ls *_sk)
  echo "the ca keyfile is $ca2_keyfile"
  cd $WORKING_PATH
  # start org3 peers
  IMAGE_TAG=$fabric_version SUPPORT_TAG=$support_version CA2_SERVER_TLS_KEYFILE=$ca2_keyfile docker-compose -f $COMPOSE_FILE_ORG3 up -d 2>&1

  # start joing org3
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start Org3 network"
    exit 1
  fi
  echo
  echo "###############################################################"
  echo "############### Have Org3 peers join network ##################"
  echo "###############################################################"
  docker exec Org3cli ./scripts/step2org3.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to have Org3 peers join network"
    exit 1
  fi
}

# Use the CLI container to create the configuration transaction needed to add
# Org3 to the network
function createConfigTx () {
  echo
  echo "###############################################################"
  echo "####### Generate and submit config tx to add Org3 #############"
  echo "###############################################################"
  docker exec cli scripts/step1org3.sh $CHANNEL_NAME $CLI_DELAY $LANGUAGE $CLI_TIMEOUT
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to create config tx"
    exit 1
  fi
}


# Generates Org3 certs using cryptogen tool
function generateCerts (){
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found. exiting"
    exit 1
  fi
  echo
  echo "###############################################################"
  echo "##### Generate Org3 certificates using cryptogen tool #########"
  echo "###############################################################"

  (cd $WORKING_PATH
   set -x
   cryptogen generate --config=./org3-crypto.yaml
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
  echo "#########  Generating Org3 config material ###############"
  echo "##########################################################"
  (cd $WORKING_PATH
   export FABRIC_CFG_PATH=$PWD
   set -x
   configtxgen -printOrg PeerOrg3MSP > ./org3.json
   res=$?
   set +x
   if [ $res -ne 0 ]; then
     echo "Failed to generate Org3 config material..."
     exit 1
   fi
  )
  cp -r $WORKING_PATH/crypto-config/ $MSPDir
  echo
}

############### running parameters ###############
CLI_TIMEOUT=10
CLI_DELAY=3
CHANNEL_NAME="testorgschannel1"
COMPOSE_FILE_ORG3='../machine4-org3.yml'
LANGUAGE=golang
rm -rf crypto-config/
rm -rf org3.json
CRYPTO_CONFIG_DIR='/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools'
MSPDir='/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen'
# org3 path: /opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/peerOrganizations/org3.example.com
fabric_version='x86_64-1.1.0'
support_version='x86_64-0.4.6'
echo "start adding new org"
addNewOrg

echo "done."
### 
# Obtain CONTAINER_IDS and remove them
function clearContainers () {
  CONTAINER_IDS=$(docker ps -aq)
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}
# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}