---
title: 持续集成之Jenkins+Gitlab简介 [二]
date: 2017-3-20 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "Jenkins" #分类 
tags: #标签 
  - Jenkins
---

![](https://i.imgur.com/m3ECCmT.jpg)

<!--more-->

# 持续集成之Jenkins+Gitlab实现持续集成 [二]


## 项目：使用git+jenkins实现持续集成

![](https://i.imgur.com/xrlpRJ6.png)

开始构建 
![](https://i.imgur.com/OeKWjwv.png)

General 

![](https://i.imgur.com/H6G4nU8.png)

源码管理 
我们安装的是`git`插件，还可以安装`svn`插件 

![](https://i.imgur.com/gsvjDug.png)

我们将`git`路径存在这里还需要权限认证，否则会出现`error` 

![](https://i.imgur.com/NL7Sl9S.png)

我们添加一个认证 

![](https://i.imgur.com/S6lGui3.png)

选择一下认证方式（我们可以在`系统管理-->Configure Credentials`）里面进行设置

**提示：gitlab有一个key，是我们用来做仓库的key。拥有的权限是`read-only`**

![](https://i.imgur.com/itJeo0T.png)

公钥我们需要在服务器上查看。

    [root@linux-node1 ~]# ssh-keygen -t rsa
    Generating public/private rsa key pair.
    Enter file in which to save the key (/root/.ssh/id_rsa):
    Created directory '/root/.ssh'.
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /root/.ssh/id_rsa.
    Your public key has been saved in /root/.ssh/id_rsa.pub.
    The key fingerprint is:
    5c:55:51:4e:a0:ad:1f:87:e0:96:9b:24:a3:09:68:62 root@linux-node2
    The key's randomart image is:
    +--[ RSA 2048]----+
    |..++o|
    |   . o o |
    |  . o . .|
    | . . . . + . |
    |  E o . S o * o .|
    | . o   . o = + o |
    |o   o .  |
    | |
    | |
    +-----------------+

**在192.168.56.11  部署的节点上，生成key**

    [root@linux-node1 ~]# cat .ssh/id_rsa.pub
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWEDIIatngRx5NaqU6t+f6FvY2RqYp3V3u5CNJS6xAamGokQ3MnbsTv/V8yKy2TpvNcXsaXmqwQtOVSAO4BzltidMPxBJUQCqKdMRbPqpzo7ZqGCuLcCfHC8M6tSbr1AaHkLbow29YbCMyzCCkjDfRcOez8yHuLj5BSFpKYCjx2wpJxoZ/Z6J8Fslsyu7MaRMvUhBMAF6mqQaC1qZ6K4BMt0IpAuJvoL4dNu9P6KcnG3Wy2zrzoKzkFUi0xpKCmpYo2bq4zRXgAFAndp44j5iMKEavWPeRH0RHTGsfE5vU5/0CI9LCRjtp/3vTaYlBryq5vNXb2abCrJXWws0jwp6L root@linux-node2

![](https://i.imgur.com/BymXalC.png)

我们设置完成后测试git是否可以拉去

    [root@linux-node2 ~]# yum install git -y
    #如果没有git命令就安装一个git客户端
    [root@linux-node1 ~]# git clone git@www.abcdocker.com:web/web-demo.git
    Cloning into 'web-demo'...
    The authenticity of host 'www.abcdocker.com (192.168.56.11)' can't be established.
    ECDSA key fingerprint is b5:74:8f:f1:03:2d:cb:7d:01:28:30:12:34:9c:35:8c.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added 'www.abcdocker.com,192.168.56.11' (ECDSA) to the list of known hosts.
    remote: Counting objects: 10, done.
    remote: Compressing objects: 100% (8/8), done.
    remote: Total 10 (delta 0), reused 0 (delta 0)
    Receiving objects: 100% (10/10), 70.00 KiB | 0 bytes/s, done.

![](https://i.imgur.com/W8yLFhH.png)


私钥：

    [root@linux-node1 ~]# cat .ssh/
    id_rsa   id_rsa.pub   known_hosts
    [root@linux-node1 ~]# cat .ssh/id_rsa
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpQIBAAKCAQEAoVULn6xsKj+XZMyFOGcFwo0bkrzFRjeZSXby/0BXJJpVaYVj
    LEMNOlbD4YHCNTQ4xmyjoeaW468pciVAooOWCCdcbjDmdmACt9knHjMZ1YRG/xuM
    DW/VTLBkP1bOAsa1NR3QE5LR/cwwFeEM/NcdjzmCVuQeSwL8GeKMKpyKWe6N8mus
    QcRLwiDElbQ9e6CqzagKYbIPnuvCr0XsYjQhGwm0Rhqt2ynr4Ig7FqUhpwmLCQtP
    nEq1MbsxDtxugKhiP6kd5znoPdazrKAD9xaRYwSoG/7F4IJMMI5hiKhVya1Bvl5n
    M3heJBv61KzW3cvOHuUch6CEt1ypybkY08R8gwIDAQABAoIBAQCXVnTZ6t9oXlDB
    EI1jlFi14LJd2tBfhuY3IOrfgFZ+knvOyX53VcrB0ARdtOAeEoezstNomysuF/EU
    D1frWu5RZcLx5tM5deT22zAzxxHT1grXYdrl++Ml1k2jkOUde5MeaYH36oErx+/P
    hlYtlAk5gmP+6Gx2Ry1/hqGfk0rBAmY/eazqpT5hc1ANuW5dCmdQ5pqHog8CwH+K
    YnhKNUaW0VMqzWg9y3cQc8tlQItWUAsjl4+l/rSdOxsC9lTtuJZfMPIlrtLPi6tg
    tfjpX+N4zRbSwVblrD6mXOcKmAPbnuvLhyIBnBmDXeAHKCEnOYJ8eEJ6rT+GRjc8
    aDvzsLmhAoGBAM0qj6lqdY4ZpHjCd7hJzGIitLBqsqRmHWgs9ymLIFQ+Z8LYI2HQ
    1xja/oUfMkAnArcjz+q+gpDinC+oOVAnr4FQWB+lUdlMzzuE6OtYyWYYzjHpdTbO
    j4tHgqkOraiuRy1TanjgAJJSwR6oTwnBIC8PjEHa3o8xslVuexOobh1TAoGBAMlO
    JUHMMVmgxDaZq0c50Bn/r/k57QGj87E9mEbJeqBs+8fcxZoOFLEEd+Sb8Q1riqV9
    12L2BAc6EoypoPUydbt0Q5/1G2VvCN1a6G43Ip7QM1cUTPrp17fvHWVSAMdq7lIr
    ntabqmtZVGqcxedmG1N7BVNXBd4Jy5HjOZ8Qfg4RAoGBAMyX5s9hNH1SIOuzscN7
    BG/QgDN1E1RR6H1cadVpwgGAgeSRuSbwJa/JowqJg4jp3hFXix1igb2N3YbA0PaX
    vLLNtjNInwh9SiLmdYdL8Pr5PZYUYykWb5rK4wdHdfHCaYRPrNuBNdC06ZRy7u6h
    QkDr1khNxKczPc1n8SA3VCe1AoGAYdWb39WIaoHquoqGppAfZnNQp/SSDkkLR6mi
    10xWT5+H4oOWeZ+8SKfeSPnM9nO8p194jXz5SjXcDAbo1iIW++qubxAlp2+GRGZJ
    Lj+XkM2pFfoky5FYqOkKRVLMVB7RAph2kuCGu7NnhoT43dRPFYxlczKJBHeIOzfO
    qlLOoLECgYEAkexlwKGeXyJj481SfqCYhjiTjCiibx/s6yS2cmamgEKOZCB2osmq
    3m9PvOAp26Sm1ISiuINNbpLY3Gi5fEvNUSyRx8HzRXP2fydvdgpltDxJUPaUVxvn
    X46F8ewsMJ7/FDLSyjdzwvoDRvKCk99OBmGmofqh5zW0GrjcQjthmbk=
    -----END RSA PRIVATE KEY-----
    [root@linux-node1 ~]#

![](https://i.imgur.com/dpMDiW1.png)

刚刚返回刚刚的区域，继续配置

![](https://i.imgur.com/t6ojevD.png)

现在我们复制`git`的`url`就不会出现验证提示 

![](https://i.imgur.com/lG45915.png)

我们选择gitlab，url如下图 

![](https://i.imgur.com/a8kkhzL.png)

查看gitlab版本

    [root@linux-node1 ~]# rpm -qa|grep gitlab
    gitlab-ce-8.14.5-ce.0.el7.x86_64

![](https://i.imgur.com/jFFW0MP.png)

我们现在就添加了一个git仓库，现在保存就可以了！ 

![](https://i.imgur.com/WoVesxD.png)

保存完毕后，我们选择立即构建 

![](https://i.imgur.com/j0JzbyA.png)

点击Console Output 可以显示控制台的输出 

![](https://i.imgur.com/tv6ldI3.png)

现在基本就算是构建成功了

转自：[持续集成之Jenkins+Gitlab实现持续集成 [二]](https://www.abcdocker.com/abcdocker/2049)