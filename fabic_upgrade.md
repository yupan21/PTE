# Hyperledger Fabric升级文档
该文档讲述使用cli对原有的网络的1.0.6网络升级到1.1.0的步骤

## 1.0.6网络结构

+ 使用networkLaunch生成1.0.6版本的fabric多机网络，示例所用的网络结构为：

        ./networkLauncher.sh -o 1 -x 2 -r 2 -p 2 -n 1 -t solo -f test -S enabled -c 2s -l INFO -q INFO -B 2000

    其中包括，一个orderer和两个org，每个org内有两个peer。
    
+ 部署多机网络的时候需要对docker-compose文件进行编排，使用两个主机进行简易的多机网络搭建。host1放置orderer和org2，host2放置org1。peer需要添加`extra_hosts`进行部署：

        extra_hosts:
          - "orderer0.example.com:172.16.50.153"
          - "orderer1.example.com:172.16.50.153"
          - "orderer2.example.com:172.16.50.153"
          - "peer0.org2.example.com:172.16.50.153"
    
+ 可以将已有的账本文件位置挂载到本地目录，方便之后进行升级。以orderer为例：

        volumes：
          - /data/ledgers_backup/orderer0.example.com:/var/hyperledger/production/orderer

    注意本地目录需要清除之前残留的账本文件
+ 如果1.0.6的网络结构已经运行，则可以通过`docker cp`的操作对账本进行备份。

+ 编排docker-compose之后分发配置文件和证书文件，然后分别按照顺序启动多机网络。包括创建channel，加入channel，安装chaincode和实例化chaincode，invoke等操作。

## 对容器进行升级

+ 使用ssh连接到各个主机，如果账本已经挂载到本地，则直接对容器进行重启，首先需要清除chaincode的容器和镜像：

    使用cleanChaincodeimage.sh清除容器和镜像

        # !/bin/bash
        # cleanChaincodeimage.sh
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

+ 使用ssh连接到各个主机，对容器进行重启，注意如果没有挂载容器的账本数据，则先对本地的目录清除，然后将账本数据进行备份，取消注释下面的代码：

    使用changeVersionScripts.sh重启容器

        # !/bin/bash
        # 使用changeVersionScripts.sh
        # usage: bash 使用changeVersionScripts.sh
        networkComposedir='106110upgrade'
        HOST1=172.16.50.153
        HOST1COMPOSE=machine1-106.1.yml
        HOST2=172.16.50.151
        HOST2COMPOSE=machine2-106.1.yml
        HOST3=172.16.50.153
        HOST3COMPOSE=machine3-106.1.yml
        PROCESS_CPU_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/process_cpu-log
        CRYPTO_CONFIG_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools
        CISCRIPT_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/scripts
        NL_DIR=/opt/go/src/github.com/hyperledger/fabric-test/tools/NL
        SCFILES_DIR=/opt/go/src/github.com/hyperledger/fabric-test/fabric-sdk-node/test/PTE/CITest/CISCFiles

        function upgradeContainer(){
            HOST=$1
            COMPOSE_FILES=$2
            Container=$3
            ledgers_data=$4
            ssh root@$1 -i ~/.ssh/id_rsa "cd $NL_DIR/$networkComposedir; \
                # 注意如果没有挂载容器的账本数据，则先对本地的目录清除，然后将账本数据进行备份，将下面三行代码取消注释
                # rm -rf /data/ledgers_backup/*/*/*; \
                # mkdir -p /data/ledgers_backup/$Container; \
                # docker cp -a $Container:/var/hyperledger/production$ledgers_data /data/ledgers_backup/$Container; \
                docker-compose -f $COMPOSE_FILES stop $Container; \
                bash cleanChaincodeimage.sh $Container
                IMAGE_TAG=x86_64-1.1.0 docker-compose -f $COMPOSE_FILES up -d --no-deps $Container; \
                echo 666 "
        }

        upgradeContainer $HOST1 $HOST1COMPOSE orderer0.example.com
        upgradeContainer $HOST2 $HOST2COMPOSE ca0
        upgradeContainer $HOST2 $HOST2COMPOSE peer0.org1.example.com
        upgradeContainer $HOST2 $HOST2COMPOSE peer1.org1.example.com
        upgradeContainer $HOST3 $HOST3COMPOSE ca1
        upgradeContainer $HOST3 $HOST3COMPOSE peer0.org2.example.com
        upgradeContainer $HOST3 $HOST3COMPOSE peer1.org2.example.com
    
    如果网络结构有变化，也可以通过添加HOST和HOSTCOMPOSE变量来修改脚本。

## 对整个网络进行升级

+ 编写cli docker-compose文件，注意需要添加extra_host和证书路径，同时需要将`capabilities.json`、`upgrade_to_v11.sh`和`utils.sh`等脚本挂载到cli容器（`./:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/`）还要注意将证书文件挂载到cli容器中：


        version: '2'


        services:
        cli:
            container_name: cli
            image: hyperledger/fabric-tools
            tty: true
            stdin_open: true
            environment:
            - GOPATH=/opt/gopath
            - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
            - CORE_LOGGING_LEVEL=INFO
            - CORE_PEER_ID=cli
            - CORE_PEER_ADDRESS=peer0.org1.example.com:7051
            - CORE_PEER_LOCALMSPID=Org1MSP
            - CORE_PEER_TLS_ENABLED=true
            - CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
            - CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
            - CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
            - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
            working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
            command: /bin/bash
            volumes:
            - /var/run/:/host/var/run/
            - /opt/go/src/github.com/hyperledger/fabric-test/fabric/common/tools/cryptogen/crypto-config/:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
            - ./:/opt/gopath/src/github.com/hyperledger/fabric/peer/scripts/
            extra_hosts:
            - "orderer0.example.com:172.16.50.153"
            - "orderer1.example.com:172.16.50.153"
            - "orderer2.example.com:172.16.50.153"
            - "peer0.org1.example.com:172.16.50.151"
            - "peer0.org2.example.com:172.16.50.153"

+ cli启动完毕之后，使用`docker exec -it cli bash`进入容器，在该示例中运行`bash ./scripts/upgrade_to_v11.sh`对网络进行升级，运行完毕后则整个升级过程结束，之后需要对chaincode进行安装和实例化。
+ 注意：在cli容器中需要使用`apt update; apt install jq`安装jq，如果无法安装，则之后的步骤不能运行，通常在局域网主机容器出现的错误是由于网络代理的原因，所以在安装的时候需要添加http_proxy和https_proxy进行代理。而在进行更新操作的时候需要取消网络代理`unset http_proxy https_proxy`
+ 下面对upgrade的步骤进行详细解释：
    1. 其中capabiliites是1.1.0网络具有的特点，需要在原有的区块配置上添加capabilities的参数，在fabric的原有网络结构上，存在`testchainid`、`<自己创建的channel, upgrade_to_v11的默认channel是testorgschannel1>`、`orderer`和`application`需要进行capabilities的修改。
    2. 所以依次需要对testchainid的orderer,testchainid的channel，testorgchannel1的orderer，testorgchannel1的application、testorgchannel1的channel进行修改。
    3. 首先需要在cli中设置orderer的环境变量，具体的值根据orderer的docker-compose文件进行修改,如示例所示：

            setOrdererGlobals() {
                CORE_PEER_LOCALMSPID="OrdererOrg"
                CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
                CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp
            }

    4. 对原有的channel进行fetch，输出为config.json

            # usage: fetchChannelConfig $CH_NAME config.json
            fetchChannelConfig() {
                CHANNEL=$1
                OUTPUT=$2

                setOrdererGlobals

                echo "Fetching the most recent configuration block for the channel"
                if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                    set -x
                    # peer channel fetch能够在本地进行fetch，但是需要修改orderer的地址为--orderer $orderer主机ip:7050 --ordererTLSHostnameOverride orderer0.example.com
                    peer channel fetch config config_block.pb -o orderer0.example.com:7050 -c $CHANNEL --cafile $ORDERER_CA
                    set +x
                else
                    set -x
                    peer channel fetch config config_block.pb -o orderer0.example.com:7050 -c $CHANNEL --tls --cafile $ORDERER_CA
                    set +x
                fi

                echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
                set -x
                GODEBUG=netdns=go configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > "${OUTPUT}"
                set +x
            }

    5. 然后对fetch下来的json配置文件进行修改，这里使用jq在cli端进行操作，按照不通的类型进行，修改的位置也不同，输出为modified_config.json：

            if [ $GROUP == "orderer" ]; then
                    jq -s '.[0] * {"channel_group":{"groups":{"Orderer": {"values": {"Capabilities": .[1]}}}}}' config.json ./capabilities.json > modified_config.json
            elif [ $GROUP == "channel" ]; then
                    jq -s '.[0] * {"channel_group":{"values": {"Capabilities": .[1]}}}' config.json ./capabilities.json > modified_config.json
            elif [ $GROUP == "application" ]; then
                    jq -s '.[0] * {"channel_group":{"groups":{"Application": {"values": {"Capabilities": .[1]}}}}}' config.json ./capabilities.json > modified_config.json
            fi
    6. 将配置文件使用configtxlator编写为pb文件

            # usage: createConfigUpdate "$CH_NAME" config.json modified_config.json config_update_in_envelope.pb

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
    7. 通过本地证书签名获取对channel的操作权限

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
                # 对于orderer本身的系统channel，只需要admin需要签名
                setOrdererGlobals
            fi

    8. 上一步需要用到setGlobals函数，用来对设置`CORE_PEER_TLS_ROOTCERT_FILE`等证书文件路径进行，需要根据不同的fabric网络配置不同的路径：

            setGlobals () {
                PEER=$1
                ORG=$2
                if [ $ORG -eq 1 ] ; then
                    CORE_PEER_LOCALMSPID="PeerOrg1"
                    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
                    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
                    if [ $PEER -eq 0 ]; then
                        CORE_PEER_ADDRESS=peer0.org1.example.com:7051
                    else
                        CORE_PEER_ADDRESS=peer1.org1.example.com:7051
                    fi
                elif [ $ORG -eq 2 ] ; then
                    CORE_PEER_LOCALMSPID="PeerOrg2"
                    CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
                    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
                    if [ $PEER -eq 0 ]; then
                        CORE_PEER_ADDRESS=peer0.org2.example.com:7051
                    else
                        CORE_PEER_ADDRESS=peer1.org2.example.com:7051
                    fi
                # 可以添加更多的组织，默认按照peerN.orgN.example.com的格式进行配置，需要自己手动修改配置信息
                # elif [ $ORG -eq 3 ] ; then
                # 	CORE_PEER_LOCALMSPID="Org3MSP"
                # 	CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
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
    9. 最后使用`peer channel update`对其进行更新操作

            if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                    set -x
                    peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer0.example.com:7050 --cafile $ORDERER_CA
                    res=$?
                    set +x
            else
                    set -x
                    peer channel update -f config_update_in_envelope.pb -c $CH_NAME -o orderer0.example.com:7050 --tls true --cafile $ORDERER_CA
                    res=$?
                    set +x
            fi
    10. 由于需要对网络结构中不通的部分进行相似的修改，将上述步骤编写为一个函数`addCapabilityToChannel`，重复调用

            #Config update for /Channel/Orderer on testchainid
            echo "Config update for /Channel/Orderer on testchainid"
            addCapabilityToChannel testchainid orderer

            sleep $DELAY

            #Config update for /Channel on testchainid
            echo "Config update for /Channel on testchainid"
            addCapabilityToChannel testchainid channel

            sleep $DELAY

            #Config update for /Channel/Orderer
            echo "Config update for /Channel/Orderer on \"$CHANNEL_NAME\""
            addCapabilityToChannel $CHANNEL_NAME orderer

            sleep $DELAY

            #Config update for /Channel/Application
            echo "Config update for /Channel/Application on \"$CHANNEL_NAME\""
            addCapabilityToChannel $CHANNEL_NAME application

            sleep $DELAY

            #Config update for /Channel
            echo "Config update for /Channel on \"$CHANNEL_NAME\""
            addCapabilityToChannel $CHANNEL_NAME channel
        
    11. 根据具体的网络结构调用`addCapabilityToChannel`，调用完毕之后整个upgrade_to_v11.sh执行结束

+ 所以对于具体的hyperledger fabric网络环境，进行升级所需要修改的配置信息主要是orderer的全局环境变量setOrdererGlobals、peer的全局环境变量setGlobals、channelName、证书文件路径，调用addCapabilityToChannel的方式。