#!/bin/bash
#
#

LOCAL=$1

echo "Leaving existing docker swarm ..."
docker swarm leave -f
echo "setting up docker swarm"
docker swarm init --advertise-addr $LOCAL


# ssh root@${HOST} -i ~/.ssh/id_rsa

# docker network create --subnet 10.10.0.0/24 --attachable --driver overlay hyperledger-ov