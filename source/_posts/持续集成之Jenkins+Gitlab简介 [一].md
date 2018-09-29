---
title: 持续集成之Jenkins+Gitlab简介 [一]
date: 2017-3-20 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "Jenkins" #分类 
tags: #标签 
  - Jenkins
---

![](https://i.imgur.com/m3ECCmT.jpg)

<!--more-->

> 摘要
> 
> DevOps（英文Development（开发）和Operations（技术运营）的组合）是一组过程、方法与系统的统称，用于促进开发（应用程序/软件工程）、技术运营和质量保障（QA）部门之间的沟通、协作与整合。它的出现是由于软件行业日益清晰地认识到：为了按时交付软件产品和服务，开发和运营工作必须紧密合作

# 持续集成之Jenkins+Gitlab简介 [一]


## 持续集成概念

> 持续集成Continuous Integration----CI
> 
> 持续交付Continuous Delivery----CD
> 
> 持续部署Continuous Deployment-----CD

### 1.1 什么是持续集成：

持续集成是指开发者在代码的开发过程中，可以频繁的将代码部署集成到主干，并进程自动化测试 

![](https://i.imgur.com/RfWel13.png)

### 1.2 什么是持续交付：
持续交付指的是在持续集成的环境基础之上，将代码部署到预生产环境 

![](https://i.imgur.com/24dMDLu.png)

### 1.3 持续部署：
在持续交付的基础上，把部署到生产环境的过程自动化，持续部署和持续交付的区别就是最终部署到生产环境是自动化的。 

![](https://i.imgur.com/lYzYHRU.png)

### 1.4 部署代码上线流程

> 1.代码获取（直接了拉取）
> 
> 2.编译  （可选）
> 
> 3.配置文件放进去
> 
> 4.打包
> 
> 5.scp到目标服务器
> 
> 6.将目标服务器移除集群
> 
> 7.解压并放置到Webroot
> 
> 8.Scp 差异文件
> 
> 9.重启  （可选）
> 
> 10.测试
> 
> 11.加入集群

## <font size="5">运维必知OWASP</font><br /> 
**Jenkins上OWASP 插件介绍**： 它是开放式Web应用程序安全项目[OWASP,Open Web Application Secunity Project] 
它每年会出一个top10的安全漏洞，我们需要知道当前top10的漏洞有哪些 

![](https://i.imgur.com/y1GdxnH.png)

[https://www.owasp.org/images/5/57/OWASP_Proactive_Controls_2.pdf](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.owasp.org/images/5/57/OWASP_Proactive_Controls_2.pdf)
 
[https://www.owasp.org/index.php/Top_10_2013-Top_10](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.owasp.org/index.php/Top_10_2013-Top_10)

## Gitlab介绍
　　GitLab是一个利用 `Ruby on Rails` 开发的开源应用程序，实现一个自托管的Git项目仓库，可通过Web界面进行访问公开的或者私人项目。 

　　GitLab拥有与Github类似的功能，能够浏览源代码，管理缺陷和注释。可以管理团队对仓库的访问，它非常易于浏览提交过的版本并提供一个文件历史库。它还提供一个代码片段收集功能可以轻松实现代码复用，便于日后有需要的时候进行查找。

### 环境准备

    [root@linux-node1 ~]# cat /etc/redhat-release 
    CentOS Linux release 7.3.1611 (Core) 
    [root@linux-node1 ~]# uname -r
    3.10.0-514.2.2.el7.x86_64
    下载epel源
    [root@linux-node1 ~]# wget http://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm 
    [root@linux-node1 ~]# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
    关闭 NetworkManager 和防火墙 
    [root@linux-node1 ~]#systemctl stop firewalld.service
    systemctl disable firewalld 
    systemctl disable NetworkManager
    关闭SELinux并确认处于关闭状态 
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    grep SELINUX=disabled /etc/selinux/config
    setenforce 0
    更新系统并重启
    [root@linux-node1 ~]# yum update -y && reboot

我们一共有2台：`192.168.56.11`和`192.168.56.12`我们安装在`192.168.56.11`上

    [root@linux-node1 /]# yum install curl policycoreutils openssh-server openssh-clients postfix -y
    [root@linux-node1 /]# systemctl start postfix
    [root@linux-node1 /]# curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
    [root@linux-node1 /]# yum install -y gitlab-ce

**由于网络问题，国内用户，建议使用清华大学的镜像源进行安装**

    [root@linux-node1 ~]# cat /etc/yum.repos.d/gitlab-ce.repo
    [gitlab-ce]
    name=gitlab-ce
    baseurl=http://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7
    repo_gpgcheck=0
    gpgcheck=0
    enabled=1
    gpgkey=https://packages.gitlab.com/gpg.key
    [root@linux-node1 ~]# yum makecache
    [root@linux-node1 /]#  yum install -y gitlab-ce

在安装一个`git`客户端

    [root@linux-node1 /]#  yum install -y git

配置并启动`gitlab-ce`

    [root@linux-node1 ~]# gitlab-ctl reconfigure
    #时间可能比较长，耐心你等待即可！----
    gitlab常用命令：
    关闭gitlab：[root@linux-node2 ~]# gitlab-ctl stop
    启动gitlab：[root@linux-node2 ~]# gitlab-ctl start
    重启gitlab：[root@linux-node2 ~]# gitlab-ctl restart
    重载配置文件: gitlab-ctl reconfigure

可以使用`gitlab-ctl`管理`gitlab`，例如查看`gitlab状态`：

    [root@linux-node1 /]#  gitlab-ctl status
    run: gitlab-workhorse: (pid 7437) 324s; run: log: (pid 7436) 324s
    run: logrotate: (pid 7452) 316s; run: log: (pid 7451) 316s
    run: nginx: (pid 8168) 2s; run: log: (pid 7442) 318s
    run: postgresql: (pid 7293) 363s; run: log: (pid 7292) 363s
    run: redis: (pid 7210) 369s; run: log: (pid 7209) 369s
    run: sidekiq: (pid 7479) 265s; run: log: (pid 7426) 326s
    run: unicorn: (pid 7396) 327s; run: log: (pid 7395) 327s

提示： 我们要保证`80`端口不被占用

我们可以查看一下端口

    [root@linux-node1 /]# gitlab-ctl restart
    ok: run: gitlab-workhorse: (pid 8353) 0s
    ok: run: logrotate: (pid 8360) 1s
    ok: run: nginx: (pid 8367) 0s
    timeout: down: postgresql: 0s, normally up, want up
    ok: run: redis: (pid 8437) 0s
    ok: run: sidekiq: (pid 8445) 0s
    ok: run: unicorn: (pid 8450) 0s
    [root@linux-node1 /]# lsof -i:80
    COMMAND  PID   USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
    nginx   8367   root7u  IPv4  54972  0t0  TCP *:http (LISTEN)
    nginx   8368 gitlab-www7u  IPv4  54972  0t0  TCP *:http (LISTEN)

**Web**：访问：192.168.56.11 


![](https://i.imgur.com/qb3g0tK.png)


**提示：**启动gitlab需要时间！

`Web`页面提示我们需要设置一个账号密码（我们要设置最少`8位数`的一个账号密码）我们设置密码为：`12345678`

　我们在后面的页面设置用户名 

![](https://i.imgur.com/7p3RFBr.png)

我们现在是以管理员的身份登陆 

![](https://i.imgur.com/IZcyIjE.png)

我们点击右上角管理区域

**第一步：**我们关闭自动注册，因为我们内部使用不需要用户自己注册，由运维分配用户即可 

![](https://i.imgur.com/o2zUf1f.png)

提示：`Save`在页面最下放！！！！！！ 记得点保存！！！！！！！！！！！！

![](https://i.imgur.com/3iuJAYf.png)

现在在查看首页就没有注册页面了

**第二步：**我们创建一个用户，在创建一个项目

先创建一个组 
![](https://i.imgur.com/tqcdM9L.png)

**提示：**gitlab上面有一个项目跟组的概念，我们要创建一个组，才可以在创建一个项目。因为gitlab的路径上首先是ip地址，其次是组 

![](https://i.imgur.com/R7y4GO6.png)

点击下方`Create group`

![](https://i.imgur.com/c2XdGQn.png)

然后我们在组里面创建项目

![](https://i.imgur.com/cd8GLto.png)

下一步： 

![](https://i.imgur.com/YqqjDvY.png)

![](https://i.imgur.com/O8Dt9Af.png)

创建完成之后它提示我们可以创建一个`key`对它进行管理

我们点击上面的`README`然后我们随便在里面写点东西 
![](https://i.imgur.com/jl4wHw7.png)

![](https://i.imgur.com/FXhIGXG.png)

填写完成我们点击前面进行查看

我们要做免密验证，现在去192.168.56.11复制下面的.ssh/id_rsa.pub

    [www@linux-node1 ~]$ cat .ssh/id_rsa.pub
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8wfTSQcSyhlsGYDSUtuxZNb1Gl3VU56nAPuxAEF2wP2ZWZ2yva354ZdKOOb6rZx2yZxqy5XIj7opBJPbhraXap+NtCH5qWyktR7dH19RBmCS7vUGgvk/5RQC0mVFrC8cztBp0M/5HxMuhVir6mD1rhbDvvaLL6S5y4gljzC1Gr2VRHIb4Et9go/38c2tqMjYCike7WWbFRyL9wTal6/146+9uREZ/r69TBTKrGuRqF44fROQP8/ly02XFjlXyl6J5NnGTk6AU855pwasX0W9aNPce3Ynrpe1TBTubmfQhrH1BwteEmg+ZXNRupxjumA+tPWfBUX+u51r/w7W/d4PD www@linux-node1
    #提示：需要提前做秘钥认证

![](https://i.imgur.com/Nvslgz7.png)

设置`Keys` 

![](https://i.imgur.com/407Swmi.png)

![](https://i.imgur.com/YNyNmLL.png)

![](https://i.imgur.com/KecV0I7.png)


添加完之后我们就可以使用`www`用户，就可以拉了 

![](https://i.imgur.com/yeg6d5y.png)

点击`Projects` 选择`SSH`，我们要将代码拉去下来

    [www@linux-node1 ~]$ cd /deploy/code/
    [www@linux-node1 code]$ ls
    web-demo
    [www@linux-node1 code]$ rm -rf web-demo/
    [www@linux-node1 ~]$ git clone  git@linux-node1:web/web-demo.git
    Cloning into 'web-demo'...
    The authenticity of host 'linux-node1 (192.168.56.11)' can't be established.
    ECDSA key fingerprint is b5:74:8f:f1:03:2d:cb:7d:01:28:30:12:34:9c:35:8c.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added 'linux-node1' (ECDSA) to the list of known hosts.
    remote: Counting objects: 3, done.
    remote: Compressing objects: 100% (2/2), done.
    remote: Total 3 (delta 0), reused 0 (delta 0)
    Receiving objects: 100% (3/3), done.
    [www@linux-node1 ~]$ ls web-demo/
    README.md
    #git clone是克隆的意思

我们来模拟开发继续写代码提交

    [www@linux-node1 ~]$ mkdir -p /web-demo
    [www@linux-node1 ~]$ vim web-demo/index.html
    [www@linux-node1 ~]$ cd web-demo/
    [www@linux-node1 web-demo]$
    [www@linux-node1 web-demo]$ ls
    index.html  README.md
    [www@linux-node1 web-demo]$ git add *
    [www@linux-node1 web-demo]$ git commit -m "add index.html"
    *** Please tell me who you are.
    Run
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
    to set your account's default identity.
    Omit --global to set the identity only in this repository.
    fatal: empty ident name (for <www@linux-node1.(none)>) not allowed

需要身份验证：

    [www@linux-node1 web-demo]$ git config --global user.email "you@example.com"
    [www@linux-node1 web-demo]$   git config --global user.name "Your Name"
    [www@linux-node1 web-demo]$ git commit -m "add index.html"
    [master be8a547] add index.html
     1 file changed, 169 insertions(+)
     create mode 100644 index.html

`git push`命令用于将本地分支的更新，推送到远程主机。它的格式与git pull命令相仿。

    [www@linux-node1 web-demo]$ git push
    warning: push.default is unset; its implicit value is changing in
    Git 2.0 from 'matching' to 'simple'. To squelch this message
    and maintain the current behavior after the default changes, use:
      git config --global push.default matching
    To squelch this message and adopt the new behavior now, use:
      git config --global push.default simple
    See 'git help config' and search for 'push.default' for further information.
    (the 'simple' mode was introduced in Git 1.7.11. Use the similar mode
    'current' instead of 'simple' if you sometimes use older versions of Git)
    Counting objects: 4, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (3/3), done.
    Writing objects: 100% (3/3), 7.66 KiB | 0 bytes/s, done.
    Total 3 (delta 0), reused 0 (delta 0)
    To git@linux-node1:web/web-demo.git
       0c1d357..be8a547  master -> master

我们的`gitlab`安装在`opt/gitlab` 
`gitlab配置文件`存放在`etc/gitlab/gitlab.rb` 

![](https://i.imgur.com/44dP3MX.png)

#现在git 需要加上主机名，我们可以修改配置文件，让它使用IP进行访问

编辑配置文件

    [root@linux-node1 ~]# vim /etc/gitlab/gitlab.rb
    external_url 'http://192.168.56.11'
    [root@linux-node1 ~]# gitlab-ctl reconfigure
    #提示：修改完需要使用reconfigure重载配置才会生效

我们从新登陆进行查看 

![](https://i.imgur.com/D1CQc9u.png)

咦！ 为啥还没改呢！ 我们从新创建一个项目在试一下

![](https://i.imgur.com/eSapsiw.png)

**友情提示：**
 
　关于Git可以查看[徐布斯博客](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.xuliangwei.com/xubusi/385.html) or [廖雪峰Git](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)

## 自动化运维之DevOps

　　DevOps（英文Development（`开发`）和Operations（`技术运营`）的组合）是一组过程、方法与系统的统称，用于促进开发（应用程序/软件工程）、技术运营和质量保障（QA）部门之间的沟通、协作与整合。 
　　它的出现是由于软件行业日益清晰地认识到：为了按时交付软件产品和服务，开发和运营工作必须紧密合作

**简单的来说DevOps是一种文化，是让开发开发、运维、测试能够之间沟通和交流**

　　自动化运维工具：saltstack、jenkins、等。因为他们的目标一样，为了我们的软件、构建、测试、发布更加的敏捷、频繁、可靠 
　　如果运维对git不熟，是无法做自动化部署。因为所有的项目都受制于开发

### Jenkins 介绍

`Jenkins`只是一个平台，真正运作的都是插件。这就是jenkins流行的原因，因为`jenkins`什么插件都有 
`Hudson`是`Jenkins`的前身，是基于`Java`开发的一种持续集成工具，用于监控程序重复的工作，`Hudson`后来被收购，成为商业版。后来创始人又写了一个`jenkins`，`jenkins`在功能上远远超过`hudson`

Jenkins官网：[https://jenkins.io/](https://jenkins.io/)

#### 安装 

**安装JDK**
 
　　Jenkins是Java编写的，所以需要先安装JDK，这里采用yum安装，如果对版本有需求，可以直接在Oracle官网下载JDK。

    [root@linux-node1 ~]# yum install -y java-1.8.0

**安装jenkins**

    [root@linux-node1 ~]# cd /etc/yum.repos.d/
    [root@linux-node1 yum.repos.d]# wget http://pkg.jenkins.io/redhat/jenkins.repo
    [root@linux-node1 ~]# rpm --import http://pkg.jenkins.io/redhat/jenkins.io.key
    [root@linux-node1 ~]# yum install -y jenkins
    [root@linux-node1 ~]# systemctl start jenkins
    #本文使用yum进行安装，大家也可以使用编译安装。

新版本的jenkins为了保证安全，在安装之后有一个锁，需要设置密码之后才可以解锁

`Jenkins Web`访问地址：192.168.56.11:8080
 
**友情提示：jenkins如果跟gitlab在一台服务器需要将jenkins的端口进行修改，需要将jenkins的8080修改为8081** 

![](https://i.imgur.com/Tk23Mbm.png)

    [root@linux-node1 ~]# cat /var/lib/jenkins/secrets/initialAdminPassword
    490a2f35a2df49b6b8787ecb27122a3a

复制这个文件下面的ID，否则不可以进行安装。

我们选择推荐安装即可

![](https://i.imgur.com/yA05XAm.png)

它会给我们安装一些基础的插件 

![](https://i.imgur.com/lwlcDrw.png)

设置用户名密码： 

![](https://i.imgur.com/EnXeKav.png)

点击保存并退出 

![](https://i.imgur.com/W8xjAfv.png)

早期jenkins默认是不需要登陆的 

![](https://i.imgur.com/7ap9hWc.png)

#### 我们先来介绍一下jenkins基础功能

我们点击`新建` 

![](https://i.imgur.com/tn2OVmU.png)

这里就是构建一个项目

**用户界面**：主要是一些用户的管理 

![](https://i.imgur.com/lv97wtU.png)

可以看到当前登陆用户及用户权限等

**任务历史：**可以查看到所有构建过的项目的历史 

![](https://i.imgur.com/nEKZGNh.png)

#之所以叫构建，是因为都是java，因为如果不是java程序就没有构建这个词。但是我们也可以把一些工作称之为构建

**系统管理：**存放jenkins所有的配置 

![](https://i.imgur.com/UhCOscZ.png)

**My Views：**视图功能，我们可以自己创建一个自己的视图 

![](https://i.imgur.com/eFKavON.png)

**构建队列：**如果当前有视图任务都会显示在这里 

![](https://i.imgur.com/zVsSb65.png)

**构建执行状态：**显示在正构建的任务 

![](https://i.imgur.com/1Kvs6T8.png)

**系统管理**：-系统设置

设置Jenkins全局设置&路径 

![](https://i.imgur.com/GS2Codu.png)

![](https://i.imgur.com/awLpI0s.png)

Jenkins系统管理比较重要的就是插件管理了 

![](https://i.imgur.com/ZxchxVo.png)

#因为jenkins所有的东西都需要靠插件来完成，

点击已安装可以查看我们的安装 

![](https://i.imgur.com/nhlLdM0.png)

我们想安装什么插件，我们可以选择可选插件

![](https://i.imgur.com/ZGghvdJ.png)

我们为了和gitlab和在一起，我们需要安装一个插件 

![](https://i.imgur.com/BhA5crz.png)

![](https://i.imgur.com/EzTmoxh.png)

查看还可以去jenkins官网下载，然后上传插件 

![](https://i.imgur.com/3r1X7vm.png)

因为很多插件需要翻墙才可以继续下载，jenkins还提供了代理的设置

> 还是在服务器目录下进行上传插件
> 
> 目录路径= /var/lib/jenkins/plugins/
> 
> 这个目录下是我们安装所有的插件

转自：[持续集成之Jenkins+Gitlab简介 [一]](https://www.abcdocker.com/abcdocker/2041)
