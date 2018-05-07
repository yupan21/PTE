# !/bin/bash
# 
# usage: bash cleanChaincodeimage.sh peer0.org1.example.com
PEER=$1
# Remove any old containers and images for this peer
CC_CONTAINERS=$(docker ps | grep dev-$PEER | awk '{print $1}')
if [ -n "$CC_CONTAINERS" ] ; then
    docker rm -f $CC_CONTAINERS
fi
CC_IMAGES=$(docker images | grep dev-$PEER | awk '{print $1}')
if [ -n "$CC_IMAGES" ] ; then
    docker rmi -f $CC_IMAGES
fi


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