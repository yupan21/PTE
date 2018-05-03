# Hyperledger Fabric部署文档
该文档包括两个部分，首先是整体fabric环境部署，涉及到fabric单机、多机网络的搭建和chaincode的部署，其次是压测环境的部署。

## Getting Started
通过以下两个链接获取部署fabric所需的证书生成工具，docker镜像和一个简单的网络结构。
+ [Prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-1.1/prereqs.html)
+ [Hyperledger Fabric Samples](https://hyperledger-fabric.readthedocs.io/en/release-1.1/samples.html)

### 运行示例详细步骤

注意：如果使用ubuntu系统则需要使用apt-get， 如果切换到root用户则不需要使用sudo

安装基础工具 

    yum update; yes | yum install curl git jq wget 

安装docker

    sudo yum remove docker docker-engine docker.io
    sudo yum update
    sudo yum install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"
    sudo yum update
    sudo yum install docker-ce
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

最后出现`All GOOD, BYFN execution completed`的时候，则表示fabric-sample能够完整的在机器上跑通了。

清除配置文件和临时文件down掉网络

    ./byfn.sh -m down

byfn的其他参数（可用来测试其他场景示例）：

    restart 重启网络（up网络时候如果需要重新起chaincode和创建channel会有BAD_REQUEST的错误，通过重启网络能够实现重新创建channel，加入channel安装chaincode等操作）
    -c channel_name 可以设置channel名字
    -i 1.0.6 可以切换fabric网络版本
    -s couchdb 可以从leveldb切换到couchdb




