# fabric添加org部署文档
该文档以在原有基础上具有4个org每个org5个peer的原有网络架构上添加一个具有5个peer的组织

# 使用PTE来起网络

进入PTE/CITtest/scenarios，运行`veredholdings-start.sh`来部署网络

+ 该命令包括分发composeFile里面的veredholdings的所有文件到需要部署的主机
+ 清除待部署主机的原有docker网络
    - 注意:使用了`docker rm -f $(docker ps -aq)``docker rmi $(docker images | grep "dev" | awk '{print $3}')`

            rm -rf /data/ledgers_backup/*
            rm -rf /data/couchdbdata/*/* #注意这里包括有douchdb的数据，挂载到本地的，测试环境需要清理
            rm -rf /data/peerdata/*/* #注意这里有peer的数据，不需要可以注释掉
            rm -rf /tmp/* 
    
+ 起网络`ENABLE_TLS=true SUPPORT_TAG=$0.4.6 IMAGE_TAG=1.1.0 docker-compose -f composefile.yaml up -d`
+ `bash test_driver.sh -m RMT-vered -p -c samplecc` 包括create channel 创建chaincode instantiate chaincode

# 使用addorg.sh添加org

进入运行fabric的主机

+ 进入PTE/composeFile/veredholdings/scripts
+ 运行addorg.sh