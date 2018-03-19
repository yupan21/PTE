## Fabric test configuration



NL option:

    ./networkLauncher.sh [opt] [value]
    options:
     -a: network action [up|down], default=up
     -x: number of ca, default=0
     -d: ledger database type, default=goleveldb
     -f: profile string, default=test
     -h: hash type, default=SHA2
     -k: number of kafka, default=0
     -z: number of zookeepers, default=0
     -n: number of channels, default=1
     -o: number of orderers, default=1
     -p: number of peers per organization, default=1
     -r: number of organizations, default=1
     -s: security type, default=256
     -t: ledger orderer service type [solo|kafka], default=solo
     -w: host ip 1, default=0.0.0.0
     -l: core logging level [CRITICAL|ERROR|WARNING|NOTICE|INFO|DEBUG], default=ERROR
     -q: orderer logging level [CRITICAL|ERROR|WARNING|NOTICE|INFO|DEBUG], default=ERROR
     -c: batch timeout, default=2s
     -B: batch size, default=10
     -F: local MSP base directory, default=$GOPATH/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen
     -G: src MSP base directory, default=/opt/hyperledger/fabric/msp/crypto-config
     -S: TLS enablement [enabled|disabled], default=disabled
     -C: company name, default=example.com

driver option:


    function testDriverHelp {

    echo "Usage: "
    echo " ./test_driver.sh [opt] [values]"
    echo "    -e: environment setup, default=no"
    echo "    -n: create network, default=no"
    echo "    -m: directory where test_nl.sh, preconfig, chaincode to be used to create network, default=scripts"
    echo "    -p: preconfigure creation/join channels, default=no"
    echo "    -s: synchup peer ledgers, recommended when network brought up, default=no"
    echo "    -c: chaincode to be installed and instantiated [all|chaincode], default=no"
    echo "    -t [value1 value2 value3 ...]: test cases to be executed"
    echo "    -b [value]: test cases starting time"
    echo " "
    echo "  available test cases:"
    echo "    FAB-query-TLS: 4 processes X 1000 queries, TLS"
    echo "    FAB-3983-i-TLS: FAB-3983, longrun: 4 processes X 60 hours invokes, constant mode, 1k payload, TLS"
    echo "    FAB-4162-i-TLS: FAB-4162, longrun: 4 processes X 60 hours mix mode, vary 1k-2k payload, TLS"
    echo "    FAB-4229-i-TLS: FAB-4229, longrun: 8 processes X 36 hours mix mode, vary 1k-2k payload, TLS"
    echo "    FAB-3989-4i-TLS: FAB-3989, stress: 4 processes X 1000 invokes, constant mode, 1k payload, TLS"
    echo "    FAB-3989-4q-TLS: FAB-3989, stress: 4 processes X 1000 queries, constant mode, 1k payload, TLS"
    echo "    FAB-3989-8i-TLS: FAB-3989, stress: 8 processes X 1000 invokes, constant mode, 1k payload, TLS"
    echo "    FAB-3989-8q-TLS: FAB-3989, stress: 8 processes X 1000 queries, constant mode, 1k payload, TLS"
    echo "    marbles-i-TLS: marbles chaincode: 4 processes X 1000 invokes, constant mode, TLS"
    echo "    marbles-q-TLS: marbles chaincode: 4 processes X 1000 queries, constant mode, TLS"
    echo "    robust-i-TLS: robustness: 4 processes X invokes, constant mode, 1k payload, TLS"
    echo "    FAB-3833-2i: 2 processes X 10000 invokes, TLS, couchDB"
    echo "    FAB-3810-2q: 2 processes X 10000 queries, TLS, couchDB"
    echo "    FAB-3832-4i: 4 processes X 10000 invokes, TLS, couchDB"
    echo "    FAB-3834-4q: 4 processes X 10000 queries, TLS, couchDB"
    echo "    FAB-3808-2i: 2 processes X 10000 invokes, TLS"
    echo "    FAB-3811-2q: 2 processes X 10000 queries, TLS"
    echo "    FAB-3807-4i: 4 processes X 10000 invokes, TLS"
    echo "    FAB-3834-4q: 4 processes X 10000 queries, TLS"
    echo " "
    echo " example: "
    echo " ./test_driver.sh -n -m FAB-3808-2i -p -c samplecc -t FAB-3808-2i: create a network, create/join channels, install/instantiate samplecc chaincode using setting in FAB-3808-2i, and execute test case FAB-3808-2i"
    echo " ./test_driver.sh -n -p -c all -t FAB-3989-4i-TLS FAB-3989-4q-TLS: create a network, create/join channel and install/instantiate all chaincodes using default setting and execute two test cases"
    echo " ./test_driver.sh -n -p -c samplecc: create a network, create/join channels, install/instantiate chaincode samplecc using default setting"
    echo " ./test_driver.sh -t FAB-3811-2q FAB-3808-2i: execute test cases (FAB-3811-2q and FAB-3808-2i)"
    exit
    }