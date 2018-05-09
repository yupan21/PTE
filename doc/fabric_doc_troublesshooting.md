# fabric故障处理文档
该文档用来记录和整理在开发和部署hyperledger fabric的时候出现的问题。持续更新中。

+ 如果出现在创建channel的时候`BAD_REQUEST`等错误，可能是由于相同channel之前已经被创建过一次。解决方案：
    - 创建不同的的channel
    - 清除fabric网络重新部署

+ 如果出现如下错误：

        Error: Error endorsing chaincode: rpc error: code = 2 desc = Error installing chaincode code mycc:1.0(chaincode /var/hyperledger/production/chaincodes/mycc.1.0 exits)

    可能是由于chaincode在之前的部署中安装并且其chaincode image已经被build。解决方案：
    - 使用`docker rmi -f $(docker images | grep peer[0-9]-peer[0-9] | awk '{print $3}')`清除image

+ 如果出现类似错误：

        Error connecting: rpc error: code = 14 desc = grpc: RPC failed fast due to transport failure
        Error: rpc error: code = 14 desc = grpc: RPC failed fast due to transport failure

    可能是由于fabric版本不兼容，请查看fabric镜像的版本，fabric证书生成工具等版本。

+ 出现类似错误：

        [configtx/tool/localconfig] Load -> CRIT 002 Error reading configuration: Unsupported Config Type ""
        panic: Error reading configuration: Unsupported Config Type ""

    由于没有设置`FABRIC_CFG_PATH`的环境变量，生成证书工具需要该环境变量。解决方案：
    - 设置环境变量`export FABRIC_CFG_PATH=$PWD`

+ 如果运行中出现类似：

        cannot assign config Capabilities and the relating parameters

    是由于证书版本不兼容，请查看fabric镜像的版本，fabric证书生成工具等版本。

+ 运行中出现`SERVICE_UNAVAILABLE`的情况存在多种故障原因。
    - 检查Orderer节点是否正确启动。如果没有正确启动，则需要重新部署。
        - 如果container已经up，则查看`docker logs -f <orderer container id>`获取log信息。
        - 如果log信息表示不够明确，则在docker-compose文件的orderer镜像中修改环境变量为DEBUG：

                ORDERER_GENERAL_LOGLEVEL=DEBUG
        - peer节点的环境变量修改：

                CORE_LOGGING_LEVEL=DEBUG
        - 在`[msp/identity] Sign`的log中出现`no valid cert`可能是由于证书文件没有配置对
        - 出现`cannot find the genesis block`等类似信息可能是由于block和channel文件路径不对或者没有生成
        - 出现`Rejecting deliver request because of consenter error`通常是因为kafka集群的连接问题，需要确保kafka集群是否正确部署，检查kafka集群是否能够成功与orderer节点进行通讯。
    - 出现如下类似错误
    
            Error: proposal failed (err: rpc error: code = Unknown desc = chaincode error (status: 500, message: Cannot create ledger from genesis block, due to LedgerID already exists))
        可能是重复操作，之前的操作中已经包括了该此操作所要达成的消息，常见在创建新org和update channel的操作，需要重新部署。

    - 检查是否启用TLS通讯，而没有使用正确的配置文件。比如`grpc`需要变成`grpcs`。
    - 检查端口是否开启，在docker-compose中端口的配置是按照

            本地端口:容器端口
        的方法进行配置的，检查是否存在端口占用和端口协议不对等的问题。

        - 注意：Docker之间的网络在常规的情况下是使用docker0作为一个网桥搭建子网进行连接的。其容器在docker内部使用其docker网络进行统一的调配所以在

                netstat -tnlp 
            命令下看到的容器对外的协议是tcp6的情况是实际上tcp6由docker0的NAT机制进行管理，同时存在tcp的对外访问方式。

+ 如果起container或者使用configtxgen，configtxlator等工具的时候出现如下类似错误：

        [signal SIGSEGV: segmentation violation code....]

    的时候，是由于pure go resoler的不支持导致的。需要在环境变量中添加

        GODEBUG=netdns=go

    来解决，如果是使用configtxgen，configtxlator等工具则需要再其命令前直接添加`GODEBUG=netdns=go`

+ 在client端对fabric网络进行操作的时候，出现Connection refuse容易存在多种故障原因：
    - 检查防火墙是否屏蔽
    - 检查代理是否开启

+ 出现couchdb的错误

    + panic错误

        CouchDB error: [couchdb] handleRequest -> DEBU 2c45 HTTP Request: GET /chain_0008/testChaincode%00key_000000222?attachments=true HTTP/1.1 | Host: 127.0.0.1:5984 | User-Agent: Go-http-client/1.1 | Accept: multipart/related | Accept-Encoding: gzip | | couchDBReturn= panic: Error:Get EOF

    等类似错误是是由于系统的文件读取的上限。可通过修改`ulimit -n`的参数来实现，如在`/etc/profile`中添加`ulimit -n 40000`的参数并`source`该文件

    + 404错误

        当并发过多的时候，会出现peer的容器down掉，然后couchdb 出现插入数据为404的log，目前的处理方案是修改

            sysctl -w net.ipv4.tcp_timestamps=1
            sysctl -w net.ipv4.tcp_tw_recycle=1
        

+ chaincode instanstiate成功，但是log中出现`cannot find the local peer`的问题是可能是由于：
    - 本地网络连接不通，尝试在chaincode的container中ping和wget所对应的peer。如果发现是走的代理路线，则可能需要通过`unset https_proxy http_proxy`或者通过添加`no_proxy=<host peer ip>`来过滤和排除代理的干扰。或者直接停止代理。注意在一些机器上，无法通过常规线路来访问ubuntu的仓库，也需要代理才能够访问。
    - docker网络问题，chaincode没有加入到docker0网桥，检查peer的环境变量`CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE`有没有设置对。

+ log中出现`docker-entrypoint.sh permission denied`，可选的错误解决方案为：
    - 通过重新拉取`docker rmi -f <出现错误的image>； docker pull <该image>`
    - 通过添加command获取权限，在command里面添加`sudo chmod 777 ./docker-entrypoint.sh`
    - 通过本地获取docker-entrypoint.sh的权限并挂载到容器中，在volume中添加。

+ 如果在fabric-sdk-node装npm的出现npy错误，需要使用yum 安装build-essential和gcc等库保证编译成功
+ 在进行`peer update`的操作的时候，需要保证写在genesis block里面的大多数组织（大于一半）的成员的签名才能够完成，否则出现（BAD_REQUEST）等情况。注意不是加入用户channel的组织，而是系统channel。
+ 1.0.6和1.1.0的fabric image所用的go的版本不一样，存在一些chaincode不能够正确的instantiate的问题，比如`undefined: sort.Slice`
+ chincode之间invoke的时候，需要在同一个peer之内才能够相互invoke，否则还是找不到这个chaincode
+ chaincode的名字和channel的名字不能用`-`来分割，否则会出现错误