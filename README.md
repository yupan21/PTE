# PTE-test

# run

## Usage

+ Make sure you joined as a swarm node in fabric

#### the main scenarios file is located on `./CITest/scenarios`

you can edit the scripts to suit you environments:

first you should set up you client and host ip address: 

    LOCAL=172.16.50.151
    HOST=172.16.50.153

to run system moniting:

    chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh
    bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/manage_host.sh $HOST

to setup a single host network;

    # start network ---
    echo "connecting host and startup the network "
    ssh root@${HOST} -i ~/.ssh/id_rsa "cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts; \
        echo \"changing network ...\"; \
        python config-network.py RMT-auto -o 3 -x 2 -r 2 -k 1 -z 1 -p 2 -n 1 -t solo -f test -w 0.0.0.0 -S enabled -c 2s -l INFO -B 500 ;\
        chmod +x ./test_nl.sh; \
        cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scenarios/network; \
        bash RMT-network-auto.sh"
    echo "sleeping 6 sec"
    sleep 6
    ## ending case ---

you can comment the scripts above if you don't want to restart the network, `config-network.py` is use to change you networklauncher, the first arguments is case name and all last argument is represent the network config

case one

    # running test-----------------
    # reconfig pte
    cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
    node ./config.js RMT-auto ccOpt.payLoadMax 2028
    node ./config.js RMT-auto nProcPerOrg 1
    node ./config.js RMT-auto invokeType Move
    bash ./test_driver.sh -t RMT-auto
    ## ending case ----------------

node is use to modify pte test case 


to end the test and transport the file to you client can use

    chmod +x /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh
    cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
    bash /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log/calculate.sh $LOCAL $HOST

    # caculate cpu log
    cd /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
    python client-main.py /opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/Logs




### python requirements

+ python2.7
+ psutil
+ pandas
+ statistics