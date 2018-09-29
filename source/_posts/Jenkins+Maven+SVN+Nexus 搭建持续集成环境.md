---
title: Jenkins+Maven+SVN+Nexus 搭建持续集成环境
date: 2017-3-22 13:15:12
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
> Jenkins只是一个平台，真正运作的都是插件。这就是jenkins流行的原因，因为jenkins什么插件都有。Hudson是Jenkins的前身，是基于Java开发的一种持续集成工具，用于监控程序重复的工作，Hudson后来被收购，成为商业版。后来创始人又写了一个jenkins，jenkins在功能上远远超过hudson
> 

![](https://i.imgur.com/Bg7d7Wt.jpg)

## 一、DevOps
> DevOps是“开发”和“运维”的缩写。
>  
> DevOps是一组最佳实践强调(IT研发、运维、测试)在应用和服务生命周期中的协作和沟通，强调整个组织的合作以及交付和基础设施变更的自动化，从而实现持续集成、持续部署和持续交付

### DevOps平台四大模块

1.项目管理          (创建项目--->>项目需求)
2.运维平台          (监控--日志收集---等)
3.持续交付          (提交完代码--->自动打包--->构建)
4.代码托管          (gitlab---->代码提交)
————————————————————>>DevOps平台
### 针对DevOps开源项目

1.项目管理---(JIRA非开源但是用的人比较多)、(Redmine使用ruby写的)
2.代码托管---(SVN--usvn有web管理界面)、(GitLab)
3.持续交付---(主流Jenkins)、(GitLab gitlab-ci也可以做交付)
4.运维平台---(国内的开源运维平台可能就是腾讯蓝鲸)

## 二、服务介绍
**很多事情不是光运维就可以决定的，还需要跟研发交流，我这里只是演示一个大概的持续交付的流程~**

### 2.1 Jenkins介绍 
`Jenkins`只是一个平台，真正运作的都是插件。这就是jenkins流行的原因，因为jenkins什么插件都有 
`Hudson`是Jenkins的前身，是基于Java开发的一种持续集成工具，用于监控程序重复的工作，Hudson后来被收购，成为商业版。后来创始人又写了一个jenkins，jenkins在功能上远远超过hudson

### 2.2 Maven 介绍 
maven的用途 
maven是一个项目构建和管理的工具，提供了帮助`管理 构建、文档、报告、依赖、scms、发布、分发`的方法。可以方便的编译代码、进行依赖管理、管理二进制库等等。 
maven的好处在于可以将项目过程规范化、自动化、高效化以及强大的可扩展性 
利用maven自身及其插件还可以获得代码检查报告、单元测试覆盖率、实现持续集成等等。

#### maven的核心概念介绍

> **Pom** 
> 
> pom是指project object Model。pom是一个xml，在maven2里为pom.xml。是maven工作的基础，在执行task或者goal时，maven会去项目根目录下读取pom.xml获得需要的配置信息
> 
> pom文件中包含了项目的信息和maven build项目所需的配置
> 
> **Artifact**
>  
> 这个有点不好解释，大致说就是一个项目将要产生的文件，可以是jar文件，源文件，二进制文件，war文件，甚至是pom文件。每个artifact都由groupId:artifactId:version组成的标识符唯一识别。需要被使用(依赖)的artifact都要放在仓库(见Repository)中
> 
> **Repositories** 
> 
> Repositories是用来存储Artifact的。如果说我们的项目产生的Artifact是一个个小工具，那么Repositories就是一个仓库，里面有我们自己创建的工具，也可以储存别人造的工具，我们在项目中需要使用某种工具时，在pom中声明dependency，编译代码时就会根据dependency去下载工具（Artifact），供自己使用。
> 
> **Build Lifecycle** 
> 
> 是指一个项目build的过程。maven的Build 
> Lifecycle分为三种，分别为default（处理项目的部署）、clean（处理项目的清理）、site（处理项目的文档生成）。他们都包含不同的lifecycle。 
> Build Lifecycle是由phases构成的
> 
> ....
>  
> 参考：[关于Maven常用参数及说明](https://blog.csdn.net/wangjunjun2008/article/details/18982089)

　　　 
### 2.3 SVN介绍 
SVN是近年来崛起的非常优秀的版本管理工具，与CVS管理工具一样，SVN是一个固态的跨平台的开源的版本控制系统。SVN版本管理工具管理者随时间改变的各种数据。这些数据放置在一个中央资料档案库repository中，这个档案库很像一个普通的文件服务器或者FTP服务器，但是，与其他服务器不同的是，SVN会备份并记录每个文件每一次的修改更新变动。这样我们就可以把任意一个时间点的档案恢复到想要的某一个旧的版本，当然也可以直接浏览指定的更新历史记录。

本站相关文章 

[SVN服务实战应用指南](https://www.abcdocker.com/abcdocker/2813)
 
[VisualSVN 迁移至Linux SVN+Apache+ssl集成LDAP](https://www.abcdocker.com/abcdocker/2818)

### 2.4 Nexus介绍

maven的仓库只有两大类：**1.本地仓库** **2.远程仓库**，在远程仓库中又分成了3种：
 
> 1 中央仓库
>  
> 2 私服 
> 
> 3 其它公共库。

私服是一种特殊的远程仓库，它是架设在局域网内的仓库服务，私服代理广域网上的远程仓库，供局域网内的Maven用户使用。当Maven需要下载构件的时候，它从私服请求，如果私服上不存在该构件，则从外部的远程仓库下载，缓存在私服上之后，再为Maven的下载请求提供服务。我们还可以把一些无法从外部仓库下载到的构件上传到私服上。

**Maven私服的 个特性：**

> 1.节省自己的外网带宽：减少重复请求造成的外网带宽消耗
> 
> 2.加速Maven构件：如果项目配置了很多外部远程仓库的时候，构建速度就会大大降低
> 
> 3.部署第三方构件：有些构件无法从外部仓库获得的时候，我们可以把这些构件部署到内部仓库(私服)中，供内部maven项目使用
> 
> 4.提高稳定性，增强控制：Internet不稳定的时候，maven构建也会变的不稳定，一些私服软件还提供了其他的功能
> 
> 5.降低中央仓库的负荷：maven中央仓库被请求的数量是巨大的，配置私服也可以大大降低中央仓库的压力
> 
> 因此我们在实际的项目中通常使用私服来间接访问中央仓库，项目通常不直接访问中央仓库

![](https://i.imgur.com/HawOag6.png)

## 三、环境搭建

> 首先最新版本2.97 只支持java1.8，我们需要将jdk版本设置为1.8
> 
> tomcat的版本最好也是8.0.x版本，如果使用8.5可能会有问题
> 
> 系统我们使用Centos7

### 3.1 配置jdk环境

    $ wget http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz
    $ tar zxf jdk-8u91-linux-x64.tar.gz -C /usr/local/
    $ ln –s /usr/local/jdk1.8.0_91 /usr/local/jdk
    $ vim /etc/profile
    export JAVA_HOME=/usr/local/jdk
    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
    export PATH=$JAVA_HOME/bin:$PATH
    检查
    $ java -version
    java version "1.8.0_151"
    Java(TM) SE Runtime Environment (build 1.8.0_151-b12)
    Java HotSpot(TM) 64-Bit Server VM (build 25.151-b12, mixed mode)

### 3.2 安装Jenkins

**提示**：首先Jenkins安装方式有2中，一种是yum安装，另一种是使用war的方式进行安装（war就需要安装tomcat）

![](https://i.imgur.com/jgqDPQC.png)

官方文档：[https://pkg.jenkins.io/redhat/](https://pkg.jenkins.io/redhat/)

如果我们想使用war包的方式可以直接下载war包 

![](https://i.imgur.com/7kAjpBe.png)

这里我们可以参考本站以前文章 [持续集成之Jenkins+Gitlab简介 [一]](https://www.abcdocker.com/abcdocker/2041)

**下载tomcat （tomcat和jdk版本最好相同）**

    $ wget http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v8.0.48/bin/apache-tomcat-8.0.48.tar.gz
    $ tar xf apache-tomcat-8.0.48.tar.gz –C /application/
    $ mv /application/apache-tomcat-8.0.48 /application/jenkins
    $ rm –rf /application/jenkins/webapps/* && mkdir –p /application/jenkins/webapps/ROOT
    下载war包
    $ wget http://mirrors.jenkins.io/war/latest/jenkins.war
    $ cp jenkins.war  /application/jenkins/webapps/ROOT/
    $unzip /application/jenkins/webapps/ROOT/jenkins.war
    我们直接执行bin/startup.sh启动就可以

启动我们可以查看tomcat日志 

![](https://i.imgur.com/MhWcas5.png)

Jenkins访问地址：localhost:8080

关于tomcat安装参数及配置修改可以参考本站 [企业必会技能tomcat](https://www.abcdocker.com/abcdocker/2514)

新版本的jenkins为了保证安全，在安装之后有一个锁，需要设置密码之后才可以解锁 

![](https://i.imgur.com/QHCq4me.png)

我们选择推荐安装即可 

![](https://i.imgur.com/0cXHEfj.png)

安装插件中 

![](https://i.imgur.com/SiVMpd5.png)

设置管理员账号密码 

![](https://i.imgur.com/u2Jl3d5.png)

登陆jenkins 

![](https://i.imgur.com/kVGYPlZ.png)

### 3.2 安装maven环境

    $ wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz
    $ tar xf apache-maven-3.5.2-src.tar.gz
    $ mv apache-maven-3.5.2 /usr/local/
    $ ln -s /usr/local/apache-maven-3.5.2/ /usr/local/maven
    $ vim /etc/profile
    export M2_HOME=/usr/local/maven
    export PATH=${M2_HOME}/bin:$PATH
    $source /etc/profile
    验证
    $ mvn -v
    Apache Maven 3.5.2 (138edd61fd100ec658bfa2d307c43b76940a5d7d; 2017-10-18T03:58:13-04:00)
    Maven home: /usr/local/maven
    Java version: 1.8.0_151, vendor: Oracle Corporation
    Java home: /usr/local/jdk1.8.0_151/jre
    Default locale: en_US, platform encoding: UTF-8
    OS name: "linux", version: "3.10.0-327.el7.x86_64", arch: "amd64", family: "unix"
    这里我们需要修改maven的settings.xml 设置一些相关配置。这里我们直接访问
    https://www.abcdocker.com/abcdocker/2893

### 3.3 安装私服(Nexus) 
下载地址：[http://www.sonatype.org/nexus/go/](http://www.sonatype.org/nexus/go/) 

![](https://i.imgur.com/C8O3GHu.png)

    $ wget https://sonatype-download.global.ssl.fastly.net/nexus/3/nexus-3.7.0-04-unix.tar.gz
    $ tar xf nexus-3.7.0-04-unix.tar.gz -C /usr/local/
    $ ln -s /usr/local/nexus-3.7.0-04/ /usr/local/nexus
    设置环境变量
    $ vim /etc/profile
    export JAVA_HOME=/usr/local/jdk
    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
    export PATH=$JAVA_HOME/bin:$PATH
    export JENKINS_HOME=/jenkins
    export M2_HOME=/usr/local/maven
    export PATH=${M2_HOME}/bin:$PATH:/usr/local/nexus/bin
    $ source  /etc/profile

启动脚本

    $ nexus 
    WARNING: ************************************************************
    WARNING: Detected execution as "root" user.  This is NOT recommended!
    WARNING: ************************************************************
    Usage: /usr/local/nexus/bin/nexus {start|stop|run|run-redirect|status|restart|force-reload}
    $ nexus start
    WARNING: ************************************************************
    WARNING: Detected execution as "root" user.  This is NOT recommended!
    WARNING: ************************************************************
    Starting nexus
    如果我们想把警告去除，需要在修改用户和环境变量。

访问地址：`localhost:8081` 端口可以在/etc/nexus-default.properties中修改）

![](https://i.imgur.com/jfsLgtB.png)

nexus登陆界面 
![](https://i.imgur.com/f2lOX3m.png)

### 3.4 Jenkins 配置 
因为我们需要构建Java项目，所以需要安装一个Maven插件 
插件名称Maven Integration plugin 
系统管理-->管理插件 
![](https://i.imgur.com/Q9yEoAC.png)

此时我们可以在已安装的插件中找到 

![](https://i.imgur.com/uHUH5Ze.png)

### 配置Jenkins全局工具配置 
`系统管理-->全局工具配置` 

![](https://i.imgur.com/t52590v.png)


配置我们的JDK、Maven地址保存就可以 


![](https://i.imgur.com/aKILFr8.png)


## 四、Jenkins构建项目
### 4.1 创建maven项目 
创建maven项目，起名称 

![](https://i.imgur.com/qGAF6y2.png)

### 4.2 设置构建参数 
这里是说我们构建的记录保留的天数与个数 

![](https://i.imgur.com/gQ8VbPy.png)

SVN地址以及账户的配置 

![](https://i.imgur.com/Iz7uH52.png)

![](https://i.imgur.com/5PBG8Sc.png)

没有问题就不会报错 

![](https://i.imgur.com/YMLaDPf.png)

这是maven的编译参数，如果有问题需要与研发的童鞋商议 

![](https://i.imgur.com/jno6MNu.png)

添加Shell脚本，添加的shell脚本可以是命令，也可以是执行一个脚本。
 
![](https://i.imgur.com/Ysyi4gz.png)

构建演示： 
![](https://i.imgur.com/NA7Bg8M.png)

这里是正在下载依赖包，因为我们项目一般在测试环境使用，是很多研发一起使用，所以这里的地址就是我们私服(Nexus地址) 

![](https://i.imgur.com/stP1ZQl.png)

执行完毕 

![](https://i.imgur.com/wWnETur.png)

当我们执行完成之后上面的shell脚本可以是将war包复制到tomcat项目目录里

/jenkins/workspace/maven/bxg-ask-center-web/target
--jenkins主目录---项目目录----代码分支-----

![](https://i.imgur.com/u5q3U7W.png)

以下是我们以前Jenkins shell中的配置，比较low 仅供参考 

![](https://i.imgur.com/jWskIDU.png)

**提示：很多相关的参数不是运维能决定的，需要研发参与**

更改Jenkins的主目录 

[https://www.cnblogs.com/zz0412/p/jenkins_jj_07.html](https://www.cnblogs.com/zz0412/p/jenkins_jj_07.html)

如何用Maven创建web项目（具体步骤）
 
[https://www.cnblogs.com/apache-x/p/5673663.html](https://www.cnblogs.com/apache-x/p/5673663.html)

Maven私服Nexus详解 

[http://blog.csdn.net/u013516966/article/details/43753143](http://blog.csdn.net/u013516966/article/details/43753143)

maven核心，pom.xml详解(转)
 
[https://www.cnblogs.com/qq78292959/p/3711501.html](https://www.cnblogs.com/qq78292959/p/3711501.html)

转自：[Jenkins+Maven+SVN+Nexus 搭建持续集成环境](https://www.abcdocker.com/abcdocker/2897)