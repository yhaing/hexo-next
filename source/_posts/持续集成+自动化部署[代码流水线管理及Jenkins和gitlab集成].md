---
title: 持续集成+自动化部署[代码流水线管理及Jenkins和gitlab集成]
date: 2017-3-22 11:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "Jenkins" #分类 
tags: #标签 
  - Jenkins
---

![](https://i.imgur.com/m3ECCmT.jpg)

<!--more-->

## 一、代码流水线管理

　　`Pipeline`名词顾名思义就是流水线的意思，因为公司可能会有很多项目。如果使用jenkins构建完成后，开发构建项目需要一项一项点击，比较麻烦。所以出现pipeline名词。 
　　代码质量检查完毕之后，我们需要将代码部署到测试环境上去，进行自动化测试

### 新建部署代码项目 

点击新建 

![](https://i.imgur.com/UASdL5X.png)

![](https://i.imgur.com/mEAnyuN.png)

这里只需要写一下描述 

![](https://i.imgur.com/F4PX4eM.png)

执行Shell脚本 

![](https://i.imgur.com/7TlnaZA.png)

**温馨提示**：执行命令主要涉及的是权限问题，我们要搞明白，jenkins是以什么权限来执行命令的。那么问题来了，我们现在192.168.56.11上，如果在想192.168.56.12上执行命令。需要怎么做呢？

**我们做无秘钥有2种分案：**

1、使用jenkins用户将秘钥分发给192.168.56.12上
 
2、使用root用户将秘钥分发给192.168.56.12上，如果使用root用户还要进行visudo授权。因为Web上默认执行命令的用户是jenkins

#### 1.我们使用root做密码验证
 
这里我们的key已经做好，如果没做可以直接 `ssh-keygen -t ras` 来生成秘钥 
我们将192.168.56.11上的公钥复制到192.168.56.12上

    [root@linux-node1 ~]# cat .ssh/id_rsa.pub
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChVQufrGwqP5dkzIU4ZwXCjRuSvMVGN5lJdvL/QFckmlVphWMsQw06VsPhgcI1NDjGbKOh5pbjrylyJUCig5YIJ1xuMOZ2YAK32SceMxnVhEb/G4wNb9VMsGQ/Vs4CxrU1HdATktH9zDAV4Qz81x2POYJW5B5LAvwZ4owqnIpZ7o3ya6xBxEvCIMSVtD17oKrNqAphsg+e68KvRexiNCEbCbRGGq3bKevgiDsWpSGnCYsJC0+cSrUxuzEO3G6AqGI/qR3nOeg91rOsoAP3FpFjBKgb/sXggkwwjmGIqFXJrUG+XmczeF4kG/rUrNbdy84e5RyHoIS3XKnJuRjTxHyD root@linux-node1
    [root@linux-node2 ~]# vim .ssh/authorized_keys
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChVQufrGwqP5dkzIU4ZwXCjRuSvMVGN5lJdvL/QFckmlVphWMsQw06VsPhgcI1NDjGbKOh5pbjrylyJUCig5YIJ1xuMOZ2YAK32SceMxnVhEb/G4wNb9VMsGQ/Vs4CxrU1HdATktH9zDAV4Qz81x2POYJW5B5LAvwZ4owqnIpZ7o3ya6xBxEvCIMSVtD17oKrNqAphsg+e68KvRexiNCEbCbRGGq3bKevgiDsWpSGnCYsJC0+cSrUxuzEO3G6AqGI/qR3nOeg91rOsoAP3FpFjBKgb/sXggkwwjmGIqFXJrUG+XmczeF4kG/rUrNbdy84e5RyHoIS3XKnJuRjTxHyD root@linux-node1
    [root@linux-node1 ~]# ssh 192.168.56.12
    The authenticity of host '192.168.56.12 (192.168.56.12)' can't be established.
    ECDSA key fingerprint is b5:74:8f:f1:03:2d:cb:7d:01:28:30:12:34:9c:35:8c.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added '192.168.56.12' (ECDSA) to the list of known hosts.
    Last login: Sat Dec 17 02:14:31 2016 from 192.168.56.1
    [root@linux-node2 ~]# ll
    total 4
    -rw-------. 1 root root 1021 Dec 13 05:56 anaconda-ks.cfg
    #现在SSH连接就不需要密码了
    授权jenkins用户，使用visudo或者编辑配置文件/etc/sudoers
    [root@linux-node1 ~]# vim /etc/sudoers
     92 jenkins ALL=(ALL)   NOPASSWD:/usr/bin/ssh
    #jenkins授权所有主机，不需要密码执行ssh。切记不要授权ALL

我们在192.168.56.12上写一个简单`shell`脚本，检测是否可以执行成功。正式环境可以写一个自动化部署的脚本

    [root@linux-node2 ~]# echo "echo "hello word"" >demo.sh
    [root@linux-node2 ~]# chmod +x demo.sh
    [root@linux-node2 ~]# ll demo.sh
    -rwxr-xr-x 1 root root 16 Dec 17 02:24 demo.sh

jenkins编写执行脚本 

![](https://i.imgur.com/DE8uL9H.png)

然后我们点击立即构建 

![](https://i.imgur.com/QwEy9DC.png)

成功！ 

![](https://i.imgur.com/wvg3sXT.png)

现在我们要将代码质量管理和测试部署连接起来。

这时候就用到了`git`钩子 
我们需要安装jenkins插件`parameterized` 

![](https://i.imgur.com/OwKZfEm.png)

我们选择`demo-deploy` 

![](https://i.imgur.com/tUYSabb.png)

再次点击项目设置的时候就会出现`Trigger parameterized build on other projects` 

![](https://i.imgur.com/h0YvqLp.png)

**提示**：`Projects to build`是为构建设置一个项目。例如我们想构建完代码项目后执行测试的，这里就填写测试的就可以。

![](https://i.imgur.com/qRU3zIk.png)

最后点击保存，点击构建。我们查看效果 

![](https://i.imgur.com/CDPoVTY.png)

![](https://i.imgur.com/oQHIjZz.png)

**这样我们每次点击`demo-deploy` 它就会在构建完成之后在对`auto-deploy`进行构建**

**下载pipeline。这样只需要构建一个项目，就会帮我们完成所有相关项目** 
搜索插件pipeline 

![](https://i.imgur.com/HjP3B46.png)

等待安装完成 

![](https://i.imgur.com/lLB5jVf.png)

我们点击首页+号，新建一个试图 

![](https://i.imgur.com/oorSWzG.png)

点击OK 

![](https://i.imgur.com/W1rRao8.png)

pipeline 配置 

![](https://i.imgur.com/xAK5dYj.png)

![](https://i.imgur.com/snDP1lF.png)

然后我们点击保存

**pipeline视图如下**： 

![](https://i.imgur.com/ECodw8A.png)

点击Run 

![](https://i.imgur.com/VwzUdFo.png)

这样就先代码质量进行管理，然后就开始部署了

构建成功后： 

![](https://i.imgur.com/sJsbPqX.png)

这样我们下次想看pipeline视图的时候，点击上面的demo-pipeline即可 

![](https://i.imgur.com/jbvzkD9.png)

## 二、Jenkins + gitlab集成

`Jenkins + gitlab`集成后，实现的功能是 开发写好代码提交至gitlab上，当时开始push到gitlab上之后，jenkins自动帮我们立即构建

这个项目我们需要安装一个`gitlab钩子`的脚本

提示： jenkins不论想实现什么功能，都需要安装插件！！

![](https://i.imgur.com/wiRoSiU.png)

安装完插件之后我们就开始配置钩子脚本 

![](https://i.imgur.com/kQX2lqv.png)

这里需要我们在服务器里面写一个令牌，在jenkins上也写一个令牌。这两个可以连接到一起就可以。

#因为用到了令牌我们还需要在安装一个插件，否则将无法使用。因为令牌是需要登录之后才会有，所以需要有一个管理的插件

插件搜索：`Build Aut` 

![](https://i.imgur.com/khwZxqt.png)

为了令牌的安全性，我们使用openssl生成一个

    [root@linux-node1 ~]# openssl rand -hex 10
    0a37c6d7ba1fe3472e26

![](https://i.imgur.com/YhFDZiu.png)

然后我们点击保存即可

因为jenkins上也提示我们需要在gitlab上添加钩子脚本

点击我们创建的项目 

![](https://i.imgur.com/pdSlWUs.png)

选中Webhooks 

![](https://i.imgur.com/Hz8UUrR.png)

Build Authorization Token Root Plugin 插件使用说明 
[https://wiki.jenkins-ci.org/display/JENKINS/Build+Token+Root+Plugin](https://wiki.jenkins.io/display/JENKINS/Build+Token+Root+Plugin)

使用Build插件后，url如下：

    http://192.168.56.11:8080/buildByToken/build?job=auto-deploy&token=0a37c6d7ba1fe3472e26
    auto-deploy=项目名称(构建时的项目名称)
    0a37c6d7ba1fe3472e26=jenkins填写的令牌

![](https://i.imgur.com/46fWs8R.png)

然后点击`Add Webhook` 

![](https://i.imgur.com/C1B4k0B.png)

下方就会出现我们这个选项，我们点击Test进行测试 

![](https://i.imgur.com/zPmCZRm.png)

测试结果 

![](https://i.imgur.com/arFqlwx.png)

向git服务器提交代码，验证是否可以自动部署：

    [root@linux-node1 ~]# echo "Build Token Root Plugin" > index.html
    [root@linux-node1 ~]# git add index.html [root@saltmaster ~/weather]# git commit -m "text"
    [root@linux-node1 ~]# git push origin master

jenkins服务器的日志记录：

    [root@linux-node1 ~]# tail -f /var/log/jenkins/jenkins.log

![](https://i.imgur.com/j3CMNiR.png)

jenkins项目构建： 

![](https://i.imgur.com/wFh4nrk.png)

访问web界面验证代码是否最新的： 
jenkins控制台输出信息： 

![](https://i.imgur.com/AjuKng3.png)

转自：[持续集成+自动化部署[代码流水线管理及Jenkins和gitlab集成]](https://www.abcdocker.com/abcdocker/2065)