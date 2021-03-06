---
title: Kubernetes集群之路（二）etcd集群部署
date: 2018-09-21 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "Kubernetes" #分类 
tags: #标签 
  - K8S
---

![](https://i.imgur.com/WeCYdWD.png)

<!--more-->

> 在前面我们生成了所有kubernetes相关的TLS证书，kubernetes集群自身所有配置相关信息都存储在etcd之中，而flannel也将网络子网网段注册到etcd之中并为集群中节点的pod提供了加入同一局域网的能力。因此接下来我们安装部署etcd集群。

因为flannel插件也依赖于etcd存储信息，所以我们首先需要安装etcd集群，使之实现高可用。

在开始之前请确保在上一篇文章中生成的TLS证书都分发到需要部署的`所有机器节点`的以下位置：

    /etc/kubernetes/ssl/etcd.pem
    /etc/kubernetes/ssl/etcd-key.pem
    /etc/kubernetes/ssl/ca.pem

## 部署etcd

我们采用纯二进制安装etcd,因此不使用默认的包管理器中的安装文件。在每台需要部署的etcd的节点上，通过官方仓库下载你需要的版本的etcd二进制安装包：

[https://github.com/coreos/etcd/releases](https://github.com/coreos/etcd/releases)

### 下载安装二进制文件

目前最新版本是[v3.3.4](https://github.com/coreos/etcd/releases/tag/v3.3.4)（截止到我写这篇文章的时候），而kubernetes v1.10验证过的版本为`3.1.12`,如果没有特殊需求请尽量使用验证版本（如果你是不升级不舒服斯基当我没说）找到对应的系统架构并直接下载: [https://github.com/coreos/etcd/releases/download/v3.1.12/etcd-v3.1.12-linux-amd64.tar.gz](https://github.com/coreos/etcd/releases/download/v3.1.12/etcd-v3.1.12-linux-amd64.tar.gz)

在所有需要安装etcd节点执行以下命令来安装`etcd`和`etcdctl`(注意:etcd目前不支持降级，如果你初始安装版本过高，后续像降级到验证版是比较麻烦的):

    wget https://github.com/coreos/etcd/releases/download/v3.1.12/etcd-v3.1.12-linux-amd64.tar.gz
    tar zxvf etcd-v3.1.12-linux-amd64.tar.gz
    cd etcd-v3.1.12-linux-amd64
    sudo mv etcd etcdctl /usr/local/bin/

### 配置systemd unit

接着，我们需要编辑对应的`systemd unit service`文件，我们需要新建一个`etcd.service`文件并放置于以下路径：`/usr/lib/systemd/system/etcd.service`并键入以下内容：

    [Unit]
    Description=Etcd Server
    After=network.target
    After=network-online.target
    Wants=network-online.target
    Documentation=https://github.com/coreos
    
    [Service]
    Type=notify
    WorkingDirectory=/var/lib/etcd/
    EnvironmentFile=-/etc/etcd/etcd.conf
    ExecStart=/usr/local/bin/etcd \
      --name ${ETCD_NAME} \
      --cert-file=${ETCD_TRUST_CERT_FILE} \
      --key-file=${ETCD_TRUST_CERT_KEY} \
      --peer-cert-file=${ETCD_TRUST_CERT_FILE} \
      --peer-key-file=${ETCD_TRUST_CERT_KEY} \
      --trusted-ca-file=${ETCD_TRUST_CA_FILE} \
      --peer-trusted-ca-file=${ETCD_TRUST_CA_FILE} \
      --initial-advertise-peer-urls ${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
      --listen-peer-urls ${ETCD_LISTEN_PEER_URLS} \
      --listen-client-urls ${ETCD_LISTEN_CLIENT_URLS} \
      --advertise-client-urls ${ETCD_ADVERTISE_CLIENT_URLS} \
      --initial-cluster-token ${ETCD_INITIAL_CLUSTER_TOKEN} \
      --initial-cluster ${ETCD_CLUSTER_NODE_LIST} \
      --initial-cluster-state new \
      --data-dir=${ETCD_DATA_DIR}
    Restart=on-failure
    RestartSec=5
    LimitNOFILE=65536
    
    [Install]
    WantedBy=multi-user.target

> `WorkingDirectory`:指定 etcd 的工作目录和数据目录为 `/var/lib/etcd`，需在启动服务前创建这个目录。
> 
> 为了保证通信安全，需要指定 etcd 的公私钥(`cert-file`和`key-file`)、Peers 通信的公私钥和CA证书(`peer-cert-file、peer-key-file、peer-trusted-ca-file`)、客户端的CA证书（`trusted-ca-file`）。
> 
> `--initial-cluster-state` 值为 `new` 时，`--name` 的参数值必须位于 `--initial-cluster` 列表中。
> 
> 我们将其中一些参数的设置抽取为环境变量，以便于我们修改参数的时候不需要再次systemctl daemon-reload。
> 
> 带有`--peer-xxx`前缀的配置为etcd与其它etcd节点通信的相关配置，不带有的该前缀的则为客户端（例如：etcdctl）与etcd节点（作为服务器）通信的相关配置。

对应的，我们在`/etc/etcd/etcd.conf`路径中新建一个`etcd.conf`文件并键入以下内容:

    # [member]
    ETCD_NAME=node1
    ETCD_DATA_DIR="/var/lib/etcd"
    ETCD_LISTEN_PEER_URLS="https://0.0.0.0:2380"
    ETCD_LISTEN_CLIENT_URLS="https://0.0.0.0:2379"
    
    ETCD_TRUST_CA_FILE="/etc/kubernetes/ssl/ca.pem"
    ETCD_TRUST_CERT_FILE="/etc/kubernetes/ssl/etcd.pem"
    ETCD_TRUST_CERT_KEY="/etc/kubernetes/ssl/etcd-key.pem"
    
    #[cluster]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.138.148.161:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_ADVERTISE_CLIENT_URLS="https://10.138.148.161:2379"
    
    ETCD_CLUSTER_NODE_LIST="node1=https://10.138.148.161:2380,node2=https://10.138.196.180:2380,node3=https://10.138.212.68:2380"
 
> 这是节点IP为10.138.148.161的环境变量配置文件内容，对于其他节点，修改对应的`ETCD_NAME`为对应的node1、node2、node3，并将`ETCD_INITIAL_ADVERTISE_PEER_URLS`和`ETCD_INITIAL_ADVERTISE_PEER_URLS`修改为对应的节点的ip。
> 
> 此处需要特别说明的是：`ETCD_CLUSTER_NODE_LIST`中的ip必须在生成etcd TLS证书时在`etcd-csr.json`中的`hosts`字段中指定（`Subject Alternative Name（SAN）`），否则可能会得到(`error "remote error: tls: bad certificate", ServerName ""`)这样的错误。
> 
> 所有需要加入的节点都需要在`ETCD_CLUSTER_NODE_LIST`中指定，并正确配置其`ETCD_NAME`。

---
### 验证etcd安装
在所有的节点上完成了上述两步之后，我们分别执行以下命令来启动etcd（初始可能会阻塞一段时间）:

    sudo systemctl daemon-reload
    sudo systemctl start etcd

如果配置正确，那么上述命令执行结果应该是任何输出的。如果结果有错，请参照上述配置和环境变量文件检查配置。一旦我们顺利启动etcd服务，我们还需要正确检查我们的`etcd`集群是否可用，在`etcd集群`中任一节点中执行以下命令：

    etcdctl --endpoint https://127.0.0.1:2379   \
    --ca-file=/etc/kubernetes/ssl/ca.pem\
    --cert-file=/etc/kubernetes/ssl/etcd.pem\
    --key-file=/etc/kubernetes/ssl/etcd-key.pem \
    cluster-health

在一切正常情况下，你会得到类似如下的输出结果:

    member 245a74588a3e85d0 is healthy: got healthy result from https://xxx.xxx.xxx.xxx:2379
    member 953bacee4a009939 is healthy: got healthy result from https://xxx.xxx.xxx.xxx:2379
    member f43a05b0ce1a8ed6 is healthy: got healthy result from https://xxx.xxx.xxx.xxx:2379
    cluster is healthy

---

### 后记

需要特别说明的是：`etcd`集群是否和`kubernetes`部署在同样的服务器节点上是`可选的`。也就是说`etcd`集群可以脱离`kubernetes`部署的集群而单独部署在其他单独的服务器上，且并不需要和`kubernetes`节点数对应。经过我的实践如果有条件的话请务必：

> 将etcd部署在kubernetes的Node节点之外负载比较低的服务器节点上。
> 
> etcd的集群数量尽量为奇数，以确保某些情况下部分etcd节点挂掉的选举问题。

至此，我们的`etcd`集群已经顺利安装完成。接下来安装flannel插件。

参考资料
[在CentOS上部署kubernetes集群](https://jimmysong.io/kubernetes-handbook/practice/install-kubernetes-on-centos.html)