# Hyperledger Fabric部署文档
该文档包括两个部分，首先是整体fabric环境部署，涉及到fabric单机、多机网络的搭建和chaincode的部署，其次是压测环境的部署。

## Getting Started
通过以下两个链接获取部署fabric所需的证书生成工具，docker镜像和一个简单的网络结构。
+ [Prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-1.1/prereqs.html)
+ [Hyperledger Fabric Samples](https://hyperledger-fabric.readthedocs.io/en/release-1.1/samples.html)

#### 详细步骤

安装基础工具 

    yum update; yes | yum install curl git jq wget 

移除


