#!/bin/bash
#
#
# Make sure you run this script on local


HOST1=120.79.163.88
HOST2=39.108.167.205
./manage_host.sh $HOST1
./manage_host.sh $HOST2

sleep 5

./calculate.sh $HOST1
./calculate.sh $HOST2