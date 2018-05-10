# fabric添加org部署文档
该文档以在原有基础上具有4个org每个org5个peer的原有网络架构上添加一个具有5个peer的组织

# 使用PTE来起网络
进入PTE/CITtest/scenarios，运行`veredholdings-start.sh`来部署网络

+ 该命令包括分发composeFile里面的veredholdings的所有文件到需要部署的主机
+ 清除待部署主机的原有docker网络
    - 注意:使用了`docker rm -f $(docker ps -aq)`和`docker rmi $(docker images | grep "dev" | awk '{print $3}')`

            rm -rf /data/ledgers_backup/*
            rm -rf /data/couchdbdata/*/* #注意这里包括有douchdb的数据，挂载到本地的，测试环境需要清理
            rm -rf /data/peerdata/*/* #注意这里有peer的数据，不需要可以注释掉
            rm -rf /tmp/* 
    
+ 起网络`ENABLE_TLS=true SUPPORT_TAG=$0.4.6 IMAGE_TAG=1.1.0 docker-compose -f composefile.yaml up -d`
+ `bash test_driver.sh -m RMT-vered -p -c samplecc` 包括create channel 创建chaincode instantiate chaincode
+ 运行100笔交易，使用的chaincode是盼盼写的资产管理


进入PTE/CITtest/scenarios，运行`veredholdings-pte.sh`来完成

# 使用addorg.sh添加org

进入运行fabric的主机

+ 进入PTE/composeFile/veredholdings/scripts
+ 运行addorg.sh

# 测试是否添加成功

进入PTE/CITtest/scenarios，运行`veredholdings-pte.sh`来测试是否能够添加org

+ 该命令包括对使用PTE安装chaincode，instantiate chaincode和运行100笔交易

# 注意
+ addorg里面的CRYPTO_CONFIG_DIR路径是使用fabric-test的绝对路径，注意修改
+ 注意文件相对位置，veredholdings里面的文件相对位置不能改变，否则大多数路径需要修改