# !/bin/bash
# 
# usage: bash cleanChaincodeimage.sh peer0.org1.example.com
$PEER=$1
# Remove any old containers and images for this peer
CC_CONTAINERS=$(docker ps | grep dev-$PEER | awk '{print $1}')
if [ -n "$CC_CONTAINERS" ] ; then
    docker rm -f $CC_CONTAINERS
fi
CC_IMAGES=$(docker images | grep dev-$PEER | awk '{print $1}')
if [ -n "$CC_IMAGES" ] ; then
    docker rmi -f $CC_IMAGES
fi