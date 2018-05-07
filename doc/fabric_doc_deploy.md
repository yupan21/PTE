# Hyperledger Fabric部署文档
该文档包括两个部分，首先是整体fabric环境部署，涉及到fabric单机、多机网络的搭建的部署。

## Getting Started
通过以下两个文档了解一个如何从头来部署hyperledger fabric区块链，文档描述了获取部署fabric所需的证书生成工具，docker镜像和一个简单的网络结构。
+ [Prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-1.1/prereqs.html)
+ [Hyperledger Fabric Samples](https://hyperledger-fabric.readthedocs.io/en/release-1.1/samples.html)

### 运行示例详细步骤

注意：如果使用ubuntu系统则需要使用apt-get， 如果切换到root用户则不需要使用sudo

安装基础工具 

    yum update; yes | yum install curl git jq wget 

安装go

    curl -O https://www.golangtc.com/static/go/1.9.2/go1.9.2.linux-amd64.tar.gz

    tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz
    vi /etc/profile #写入下面两行，不要注释
    # export PATH=$PATH:/usr/local/go/bin
    # export GOPATH=/opt/go
    source /etc/profile
    echo $PATH
    go version

安装docker

    sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
    sudo yum update
    sudo yum install -y yum-utils \
        device-mapper-persistent-data \
        lvm2
    yum-config-manager \
        --add-repo \
        https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum update
    sudo yum install docker-ce
    systemctl start docker
    # sudo docker run hello-world # 可用来测试docker是否安装成功
    docker --vresion

安装docker-compose

    sudo yum install python-pip
    sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version

通过nvm安装npm

    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

安装nvm后需要新开一个窗口进行如下指令

    nvm install 8.9.4
    nvm alias default 8.9.4

克隆fabric sample的repo

    mkdir -p /opt/go/src/github.com/hyperledger
    cd /opt/go/src/github.com/hyperledger/
    git clone -b master https://github.com/hyperledger/fabric-samples.git
    cd fabric-samples
    git checkout v1.1.0

下载fabric证书生产，配置文件，镜像生成等执行文件

    curl -sSL https://goo.gl/6wtTN5 | bash -s 1.1.0 # 需要通过代理访问，而且下载较慢
    # 可以拷贝在其他机器上已经下载好的配置文件
    # mkdir -p ./bin
    # scp -i ~/.ssh/id_rsa -r root@172.16.50.151:~/bin ./bin

fabric-sample的根目录下的`bin`文件位该执行文件位置，在运行该示例的时候需要用到； 也可以将bin复制到`～/bin `下并设置`PATH`环境变量供之后的部署和测试使用：

    mkdir -p ~/bin
    cp -r ./bin ~/bin
    # 添加环境变量到/etc/profile
    # vi /etc/profile
    # export PATH=$PATH:~/bin

运行一遍fabric示例以查看是否部署成功

    # 定位到 fabric-samples的文件位置
    cd fabric-samples/first-network

生成证书

    ./byfn.sh -m generate

起网络并且进行，创建channel，加入channel，安装chaincode，instantiate chaincode，invoke和query等操作

    ./byfn.sh -m up

最后出现`All GOOD, BYFN execution completed`的时候，则表示fabric-sample的单机模式能够完整的在机器上跑通了。

清除配置文件和临时文件down掉网络

    ./byfn.sh -m down

byfn的其他参数（可用来测试其他场景示例）：

    restart 重启网络（up网络时候如果需要重新起chaincode和创建channel会有BAD_REQUEST的错误，通过重启网络能够实现重新创建channel，加入channel安装chaincode等操作）
    -c channel_name 可以设置channel名字
    -i 1.0.6 可以切换fabric网络版本
    -s couchdb 可以从leveldb切换到couchdb

### byfn示例说明

上面的示例是用来部署完整的具有基本hyperledger fabric功能的示例。如果部署存在障碍，可以查看fabric故障处理文档来解决。下面来说明byfn的在部署过程中的操作流程。


+ byfn使用`cryptogen`工具为我们生成各种网络实体的加密材料（x509证书）。这些证书是身份的代表，它们允许在网络进行交流和交易时进行签名/验证身份验证。
+ `cryptogen`通过`crypto-config.yaml`来进行生产其所需文档，配置的每个参数都有注释可以在该文件中查看。生成的证书等文件保存在`crypto-config`中。
+ `configtxgen`用于创建4个配置文件： orderer的genesis block, channel的channel configuration transaction, * 以及anchor peer transactions分别对应一个组织。
+ script.sh脚本被拷贝到CLI容器中。这个脚本驱动了使用提供的channel name以及信道配置的channel.tx文件的createChannel命令。
+ createChannel命令的产出是一个创世区块-`genesis.block`-这个创世区块被存储在peer节点的文件系统中同时包含了在channel.tx的信道配置。
+ joinChannel命令被4个peer节点执行，作为之前产生的genesis block的输入。这个命令介绍了peer节点加入mychannel以及利用mychannel.block去创建一条链。
+ 现在我们有了由4个peer节点以及2个组织构成的信道。这是我们的TwoOrgsChannel配置文件。
+ `peer0.org1.example.com`和`peer1.org1.example.com`属于Org1;peer0.org2.example.com和peer1.org2.example.com属于Org2
+ 这些关系是通过crypto-config.yaml定义的，MSP路径在docker-compose文件中被指定。
+ `Org1MSP(peer0.org1.example.com)`和`Org2MSP(peer0.org2.example.com)`的anchor peers将在后续被更新。我们通过携带channel的名字传递Org1MSPanchors.tx和Org2MSPanchors.tx配置到排序服务来实现anchor peer的更新。
+ 一个chaincode-chaincode_example02被安装在peer0.org1.example.com和peer0.org2.example.com
+ 这个chaincode在peer0.org2.example.com被实例化。实例化过程将chaincode添加到channel上，并启动peer节点对应的容器，并且初始化和chaincode服务有关的键值对。示例的初始化的值是[”a“,”100“，”b“，”200“]。实例化的结果是一个名为dev-peer0.org2.example.com-mycc-1.0的容器启动了。
+ 实例化过程同样为背书策略传递相关参数。策略被定义为-P "OR    ('Org1MSP.member','Org2MSP.member')"，意思是任何交易必须被Org1或者Org2背书。
+ 一个针对a的查询发往`peer0.org1.example.com`。chaincode已经被安装在了`peer0.org1.example.com`，因此这次查询将启动一个名为dev-peer0.org1.example.com-mycc-1.0的容器。查询的结果也将被返回。没有写操作出现，因此查询的结果的值将为100。
+ 一次invoke被发往peer0.org1.example.com，从a转移10到b。
+ 然后chaincode服务被安装到peer1.org2.example.com
+ 一个query请求被发往peer1.org2.example.com用于查询a的值。这将启动第三个chaincode服务名为dev-peer1.org2.example.com-mycc-1.0。返回a的值为90,正确地反映了之前的交易，a的值被转移了10。
+ byfn通过其脚本的`replace_private`函数来替换CA_key用来确保ca能够成功启动。如果手动部署网络的时候，需要手动将其替换成生成的文件。其需要替换的位置在

        environment:
          - FABRIC_CA_SERVER_TLS_KEYFILE=<key path>

        command: sh -c 'fabric-ca-server start --ca.certfile "<key path>"

+ 通过`docker-compose -f <compose file> up -d `来启动配置好在docker-compose文件中hyperledger fabric网络。
+ 独立配置docker-compose的时候需要注意的情况：

    - core_peer_chaincodeListenAddress默认为7052，如果没有设置的化会有警告。但是在开发的时候如果chaincode监听端口没有额外改变一般不需要作出修改，如果peer无法和chaincode进行通讯可以通过该参数进行端口排查
    - `CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE`需要的默认设置为`{文件夹名称}_default`，在写docker-compose文件的时候需要写对。否则可能会出现chaincode无法和peer通讯
    - `depends_on`参数主要是用来保证container启动的顺序的，常规的启动顺序是`kafka/zk->orderer->couchdb->peer`。
    - `links`的作用有保证启动顺序和通过类似修改namespace的机制进行连接，如果是单机网络则可以不用配置。
    - `extra_host`和`external_link`的配置可以用来起多机网络，之后再详细讨论。
+ 如果需要使用自己的chaincode则需要

##使用nodesdk进行部署hyperledger fabric
在本次实例中通过fabric-sample生成的证书来部署

+ 获取fabric-sample sdk
    cd /opt/go/src/github.com/hyperledger
    git clone https://github.com/hyperledger/fabric-sdk-node.git
    cd fabric-sdk-node
    npm install

+ 将证书文件复制过去

        cd /opt/go/src/github.com/fabric-sdk-node/test/fixtures/channel
        cp -r /opt/go/src/github.com/fabric-samples/first-network/crypto-config .
        cp -ri /opt/go/src/github.com/fabric-samples/first-network/channel-artifacts/* .

+ 填写config.json文件（位置根据具体的证书位置来填写）


        vi /opt/go/src/github.com/fabric-sdk-node/test/integration/e2e/config.json

        -                       "tls_cacerts": "../../fixtures/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tlscacerts/example.com-cert.pem"
        +                       "tls_cacerts": "../../fixtures/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
        -                               "tls_cacerts": "../../fixtures/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tlscacerts/org1.example.com-cert.pem"
        +                               "tls_cacerts": "../../fixtures/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert
        -                               "requests": "grpcs://localhost:8051",
        -                               "events": "grpcs://localhost:8053",
        +                               "requests": "grpcs://localhost:9051",
        +                               "events": "grpcs://localhost:9053",
        -                               "tls_cacerts": "../../fixtures/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tlscacerts/org2.example.com-cert.pem"
        +                               "tls_cacerts": "../../fixtures/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert
        vi ../../unit/util.js
        -       var keyPath = path.join(__dirname, util.format('../fixtures/channel/crypto-config/peerOrganizations/%s.example.com/users/Admin@%s.example.com/keystore', userOrg, userOrg));
        +       var keyPath = path.join(__dirname, util.format('../fixtures/channel/crypto-config/peerOrganizations/%s.example.com/users/Admin@%s.example.com/msp/keystore', userOrg, userOrg));
        -       var certPath = path.join(__dirname, util.format('../fixtures/channel/crypto-config/peerOrganizations/%s.example.com/users/Admin@%s.example.com/signcerts', userOrg, userOrg));
        +       var certPath = path.join(__dirname, util.format('../fixtures/channel/crypto-config/peerOrganizations/%s.example.com/users/Admin@%s.example.com/msp/signcerts', userOrg, userOrg));
        -       var keyPath = path.join(__dirname, '../fixtures/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/keystore');
        +       var keyPath = path.join(__dirname, '../fixtures/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/keystore');
        -       var certPath = path.join(__dirname, '../fixtures/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/signcerts');
        +       var certPath = path.join(__dirname, '../fixtures/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts');

+ 清除临时的签名文件

        rm -rf /tmp/hfc*

+ nodejs test执行顺序

        node create-channel.js
        node join-channel.js
        node install-chaincode.js
        node instantiate-chaincode.js
        node invoke-transaction.js
        node query.js
+ 如果需要使用自己的chaincode则需要在`fabric-sdk-node/test/util/util.js`中的`CHAINCODE_UPGRADE_PATH`更改为自己的chaincode
+ 使用`invoke-transaction`和`query`的时候需要根据自己的chaincode的规则替换invoke和query值。
+ 详细sdk的文档主要见[hyperledger fabric node sdk](https://fabric-sdk-node.github.io)


## 多机网络部署
多机网络部署存在多种方法，这里仅讨论通过给容器添加hosts完成部署

+ 使用[networklaunch工具](https://github.com/hyperledger/fabric-test/tree/master/tools/NL)来进行生成证书和生成docker-compose文件等操作，注意该工具仅能够应用于1.1.0的fabric版本。同时在生成完配置文件之后会自动部署一个单机网络。所以我们需要注释掉`gen_network.sh`中`docker-compose -f docker-compose.yml up -d $tmpOrd`等的命令。
+ 编写docker-compose文件
    - 按照生成的docker-compose.yml文件来分割成不通host里面需要部署的节点。需要修改的部分为：
    1. 在每个peer中添加extra_hosts参数，指向需要进行连接的host，详细的联通方式查看[Transaction Flow](https://hyperledger-fabric.readthedocs.io/en/release-1.1/txflow.html)。
    2. 去除depends_on的对于没有在该主机的容器的参数。比如在某个部署peer的机器上不需要depends on orderer节点
    3. 注意启动顺序kafka/zk集群-orderer-couchdb-peer
    4. 注意保证ca证书的正确填写。
    5. 将生成的证书分发到各个需要部署的节点，注意保证路径的一致

            scp -i ~/.ssh/id_rsa -r <本地主机文件> root@<远程主机ip>:/远程主机文件路径

    6. 在其中一个client主机上通过ssh来起多机网络，示例如下

            HOST1=远程主机一
            HOST2=远程主机二
            networkCompose=docker-compose文件夹
            HOST1COMPOSE=主机一的部署容器
            HOST2COMPOSE=主机二的部署容器
            NL_DIR=networklaunch工具路径
            # cleanup the network and restart ------------
            function clean_network(){
                echo "Connecting to $1 to cleanup the network."
                ssh root@$1 -i ~/.ssh/id_rsa "cd $NL_DIR; \
                    ./cleanNetwork.sh example.com; \
                    rm -rf /tmp/* "
            }
            rm -rf /tmp/*
            clean_network $HOST1
            clean_network $HOST2
            # cleanup the network ------------

            function startup_network() {
                echo "Connecting to $1 to startup the network."
                echo "Startup $2"
                ssh root@$1 -i ~/.ssh/id_rsa "cd $NL_DIR/$networkCompose; \
                    docker-compose -f $2 up -d "
            }
            # startup the network ------------
            startup_network $HOST1 $HOST1COMPOSE
            startup_network $HOST2 $HOST2COMPOSE
    7. 测试创建channel，join channel，install chaincode，instantiate chaincode可以通过之前提到的node sdk的方法来进行（注意需要修改配置文件位对应的机器）。


## Rereference

+ 查看[架构设计](https://hyperledger-fabric.readthedocs.io/en/release-1.1/architecture.html)可了解有关hyperledger fabric交易流程的文档
+ 查看[fabric test](https://github.com/hyperledger/fabric-test)了解压测部署