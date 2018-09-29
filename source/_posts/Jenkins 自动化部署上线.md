---
title: Jenkins 自动化部署上线
date: 2017-3-23 15:20:12
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
> jenkins自动化部署项目,通过jenkins 部署来节省运维时间,不需要手动cp上线及版本发布

![](https://i.imgur.com/wDvpDqM.jpg)

## 一、Jenkins是什么

> Jenkins是一款自包含的开源自动化服务,可用于自动执行与构建,测试和交付或部署软件有关的各种任务。
> 
> Jenkins目前可以通过本地系统软件包Docker进行安装,甚至可以通过任何安装了Java运行环境的计算机独立运行

## 二、上线流程图

> 既然我们说到自动化上线,我们就不得不说说一个项目上线的流程.只有规范起来才可以做到不出事故！

**上线流程图如下图所示** 

![](https://i.imgur.com/HyWzu9X.png)

## 三、Jenkins安装配置
> Jenkins依赖Java环境,我们需要安装Java环境以及相关的环境准备

    ###关闭防火墙
    $ iptables -F
    $ iptables -X
    $ systemctl stop firewalld
    $ systemctl disable firewalld
    ###安装yum源
    $ wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    $ wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    $ yum clean all && yum makecache   

### 1.下载Jdk包 

![](https://i.imgur.com/feXnupT.png)

下载地址：[http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

上传jdk包到服务器

    ###解压拷贝jdk
    $ tar xf jdk-8u171-linux-x64.tar.gz -C /usr/local/
    $ ln -s /usr/local/jdk1.8.0_171/ /usr/local/jdk
    $ ln -s /usr/local/jdk/bin/java /usr/bin/java
    ###设置环境变量
    $ vim /etc/profile
    export JAVA_HOME=/usr/local/jdk
    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
    export PATH=$JAVA_HOME/bin:$PATH
    $ source  /etc/profile

### 2.安装Jenkins

    $ wget  -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    $ rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
    $ yum install jenkins -y
    $ systemctl start jenkins
    ##如果我们启动Jenkins出现错误可以直接使用systemctl status jenkins查看错误

**jenkins相关目录释义：**

    (1)/usr/lib/jenkins/：jenkins安装目录，war包会放在这里。
    (2)/etc/sysconfig/jenkins：jenkins配置文件，“端口”，“JENKINS_HOME”等都可以在这里配置。
    (3)/var/lib/jenkins/：默认的JENKINS_HOME。
    (4)/var/log/jenkins/jenkins.log：jenkins日志文件。

检查端口是否存在 

![](https://i.imgur.com/Hm1dfY8.png)

### 3.配置Jenkins 

![](https://i.imgur.com/QYyelUn.png)

Jenkins有安全策略,我们按照提示拷贝验证码即可 

![](https://i.imgur.com/PqLAbhR.png)

将验证码复制到Web框里 

![](https://i.imgur.com/evwluLw.png)

我们这里使用推荐就可以了，因为后期我们都可以在安装 

![](https://i.imgur.com/DqzWOw7.png)

安装插件中，有的插件会因为网络问题无法安装成功

![](https://i.imgur.com/lxtDKKR.png)

我们这里可以创建一个管理员，或者直接使用admin

**我们最好不要直接使用**`admin`

![](https://i.imgur.com/i21OgmG.png)


![](https://i.imgur.com/5eGPRQX.png)


安装完成访问地址：`iP:8080` 

![](https://i.imgur.com/seNy0Mu.png)

到这里我们Jenkins已经安装成功,剩下的就是配置插件和配置环境

![](https://i.imgur.com/PdVxXB2.png)


因为我们目前什么都没有需要安装插件,点击下步安装插件 

![](https://i.imgur.com/xesbGk5.png)

> 为了模拟环境我们需要安装Jenkins一些相关插件 
> 
> 下面2个maven 插件都需要勾选 
> 
> 插件名称:`maven lntergration`

![](https://i.imgur.com/pWTox30.png)

我们勾选安装重启 

![](https://i.imgur.com/zDvBCOF.png)

![](https://i.imgur.com/aHh587A.png)

安装完成后如下图所示 
**默认是没有下面的maven项目的**

![](https://i.imgur.com/p8JZzCx.png)

### 4.Jenkins配置项目

配置SVN地址 
因为我是新建的Jenkins目录,没有权限,所以需要创建一个用于认证. 

![](https://i.imgur.com/RfEwyXL.png)

> 填写SVN地址，因为我这里的svn已经链接到ldap,所以不需要输入svn的密码,默认这里是svn的用户和密码

具体文章可以参考 [VisualSVN 迁移至Linux SVN+Apache+ssl集成LDAP](https://www.abcdocker.com/abcdocker/2818)

![](https://i.imgur.com/VHvUYLQ.png)

认证成功之后 

![](https://i.imgur.com/kaem4sA.png)

**了解maven 配置** 
首先我们的svn分支下面需要有pom.xml 

![](https://i.imgur.com/d9tlycP.png)

继续往下 
↓ 
↓ 
↓ 
↓ 
因为我们只安装maven的插件，并没有安装maven服务，所以这里需要我们配置 

![](https://i.imgur.com/E1K5Yu7.png)

我们就在这里添加一个名字，maven就自动安装了 

![](https://i.imgur.com/uf6dC8i.png)

> Maven安装完成了，需要依赖吧都是从maven.apache.org下载会比较慢，所以我们指定私服的地址,因为在实际生产中也都是使用私服的。
> 
> 在maven的配置文件里面也需要配置 配置文件conf/settings.xml 因为我们所使用的是Jenkins的自动安装，而不是指定路径所以我们要查到这个配置文件

maven 自动安装的配置路径 

![](https://i.imgur.com/JqiEkWu.png)

配置Maven仓库地址

**这里配置的都是私服地址** 

相关文章 [Jenkins+Maven+SVN+Nexus 搭建持续集成环境](https://www.abcdocker.com/abcdocker/2897)

![](https://i.imgur.com/l8oset7.png)

配置Maven 镜像地址 

![](https://i.imgur.com/86Zb3xU.png)

配置Maven 编译参数 [研发都会]

相关文章：[maven 编译命令](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://blog.csdn.net/superit401/article/details/51355241) 

![](https://i.imgur.com/KsehCr1.png)

> 这个pom.xml里面配置是私服的地址
> 
> 因为代码里面有很多东西是需要拉去依赖包，这些依赖包就存放在本地的私有仓库里(Nexus)

**代码中pom.xml配置如下** 
私有仓库的地址 

![](https://i.imgur.com/IfvzHE3.png)

### 5.构建测试 

![](https://i.imgur.com/xy0Ec4x.png)

**控制台输出说明**

![](https://i.imgur.com/2kpPnuc.png)


![](https://i.imgur.com/o1cH3Bl.png)

![](https://i.imgur.com/oQbEK3y.png)


### 6.Jenkins 工程目录

![](https://i.imgur.com/Yghks1I.png)


可以通过修改Jenkins主目录


![](https://i.imgur.com/588I5Zu.png)

Jenkins打包好后的目录，这个war包就是我们需要拷贝的tomcat下面的 

![](https://i.imgur.com/TIqQ6u0.png)

## 四、Jenkins 自动化部署项目案例
**因为目前环境原因，我这里只是截图Jenkins发布的流程(本次演示只是针对测试环境日常发布版本)**

<font size="5">(1) Java 环境演示 [Jenkins和Tomcat在一台服务器上]</font><br />
**1.Jenkins 配置**

![](https://i.imgur.com/mNjESfi.jpg)

SVN部分配置 

![](https://i.imgur.com/exzsuFD.png)

maven及脚本设置 

![](https://i.imgur.com/MZhHKw4.png)

**2.不发脚本配置如下：** 

相关参考：[Jenkins可用环境变量列表](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.cnblogs.com/EasonJim/p/6758382.html) 
脚本的存放路径可以在`系统管理->全局配置->Jenkins路径`

    Last login: Thu Jun 28 18:01:59 2018 from 172.16.29.39
    [root@tomcat ~]# cat /jenkins/deploy.sh
    #!/bin/bash
    #
    # Jenkins工程构建通用TOMCAT部署脚本
    # @author abcdocker
    # @create_time 2017-08-19
    #
    # 在Jenkins内配置部署单元参数
    #  参数格式：MAVEN_MODULE_NAME:TOMCAT_ABSOLUTE_PATH  MAVEN模块名称:需要部署的目标TOMCAT绝对路径
    #  只有单个部署单元且没有Maven子模块时，模块名称参数可以没有，参数格式为：TOMCAT_ABSOLUTE_PATH
    #
    # 注意：
    #  在本部署脚本内会执行TOMCAT启动脚本，为避免Jenkins在构建成功以后杀掉所有衍生的后台进程，需要在Jenkins内配置全局环境变量 BUILD_ID 值为 allow_to_run_as_daemon
    #
    #
    DEPLOY_TARGET_TOMCAT=$TOMCAT
    #校验部署参数，不能为空
    if [ -z "$DEPLOY_TARGET_TOMCAT" ]
    then
    echo
    echo 部署参数为空，部署失败！
    echo "#####################################################################"
    echo
    echo 单个部署单元参数格式：
    echo  MAVEN_MODULE_NAME:TOMCAT_ABSOLUTE_PATH MAVEN模块名称:需要部署的目标TOMCAT绝对路径
    echo
    echo 多个部署单元参数格式：（多个部署单元使用空格分割）
    echo  MAVEN_MODULE_NAME:TOMCAT_ABSOLUTE_PATH MAVEN_MODULE_NAME:TOMCAT_ABSOLUTE_PATH
    echo
    echo "#####################################################################"
    exit 1
    fi
    echo
    echo 部署参数：${DEPLOY_TARGET_TOMCAT}
    TOMCAT_ARR=${DEPLOY_TARGET_TOMCAT//;/ }
    ARR=($TOMCAT_ARR)
    ARR_LEN=${#ARR[*]}
    echo 共 ${ARR_LEN} 个部署单元
    i=1
    #获取Jenkins传入的目标TOMCAT组
    for T in $TOMCAT_ARR
    do
    echo
    echo 开始 处理第 ${i} 个部署单元
    echo 第一个部署单元：$T
    #获取目标TOMCAT的WAR路径和TOMCATA的绝对路径
    TOMCAT_PARAM=(${T//:/ })
    MODULE_NAME=${TOMCAT_PARAM[0]}
    TARGET_TOMCAT_PATH=${TOMCAT_PARAM[1]}
    WAR_PATH="$WORKSPACE/$MODULE_NAME/target/*.war"
    echo 部署单元模块名称："${MODULE_NAME}"
    echo 部署WAR包路径："${WAR_PATH}"
    echo 部署TOMCAT路径："${TARGET_TOMCAT_PATH}"
    #需要考虑MAVEN单模块下的部署问题
    #if [ "${#ARR[*]}" -eq 1 -a -z "$TARGET_TOMCAT_PATH" ]
    if [ "$ARR_LEN" -eq 1 -a -z "$TARGET_TOMCAT_PATH" ]
    then
    #MAVEN过程没有子模块，单个部署单元
    TARGET_TOMCAT_PATH=$MODULE_NAME
    MODULE_NAME="NULL"
    fi
    #校验参数，WORKSPACE变量来自于Jenkins环境变量
    if [ -z "$MODULE_NAME" -o ! -f $WAR_PATH ]
    then
    echo 错误：MAVEN部署模块名称 参数为空 或 找不到WAR包！
    echo 部署失败！
    exit 1
    fi
    if [ -z "$TARGET_TOMCAT_PATH" -o ! -d "$TARGET_TOMCAT_PATH" ]
    then
    echo 错误：目标TOMCAT绝对路径 参数为空 或 该TOMCAT目录不存在！
    echo 部署失败！
    exit 1
    fi
    echo 开始清理目标TOMCAT启动进程...
    TOMCAT_PID=`ps -ef |grep "$TARGET_TOMCAT_PATH" |grep  "start" |awk '{print $2}'`
    if [ -n "$TOMCAT_PID" ]
    then
    echo TOMCAT_${i}，PID${TOMCAT_PID}，正在结束该进程...
    kill -9 $TOMCAT_PID && echo PID${TOMCAT_PID} 已被干掉！
    else
    echo TOMCAT_${i} 进程未启动！
    fi
    echo 开始清理目标TOMCAT缓存...
    rm -rf $TARGET_TOMCAT_PATH/webapps/*
    rm -rf $TARGET_TOMCAT_PATH/logs/*
    rm -rf $TARGET_TOMCAT_PATH/work/*
    echo 开始部署WAR包...
    cp -a $WAR_PATH $TARGET_TOMCAT_PATH/webapps/ROOT.war && echo WAR包部署完毕。
    echo 开始启动目标TOMCAT服务...
    sleep 10
    /bin/bash $TARGET_TOMCAT_PATH/bin/startup.sh
    echo 开始配置web目录的FTP权限...
    #启动过程会自动解压WAR包，所以在这里需要等待WAR包解压完成再调整目录权限
    sleep 30
    chown -R vftpuser.vftpuser ${TARGET_TOMCAT_PATH}/webapps/ && echo 目录权限配置完毕。
    echo 部署成功
    echo 完成 第 ${i} 个部署单元处理。
    echo
    ((i++))
    done

**3.构建效果如下图所示**： 

![](https://i.imgur.com/BP9P36G.gif)

<font size="5">(2) Java 环境演示 [Jenkins和Tomcat不在一台服务器上]</font><br />
上面的脚本是针对Jenkins和Tomcat都在相同的目录,有的时候我们测试环境会存在不在一台服务器的情况,脚本如下

只是脚本简单的修改

    [root@tomcat ~]# cat /jenkins/ysc.sh
    #!/bin/bash
    #
    # Jenkins工程构建通用TOMCAT部署脚本
    # @author 刘曙
    # @create_time 2017-08-19
    #
    # 在Jenkins内配置部署单元参数
    #  参数格式：MAVEN_MODULE_NAME:TOMCAT_ABSOLUTE_PATH  MAVEN模块名称:需要部署的目标TOMCAT绝对路径
    #  只有单个部署单元且没有Maven子模块时，模块名称参数可以没有，参数格式为：TOMCAT_ABSOLUTE_PATH
    #
    # 注意：
    #  在本部署脚本内会执行TOMCAT启动脚本，为避免Jenkins在构建成功以后杀掉所有衍生的后台进程，需要在Jenkins内配置全局环境变量 BUILD_ID 值为 allow_to_run_as_daemon
    #
    #
    DEPLOY_TARGET_TOMCAT=$YSC
    HOST=root@172.16.1.35
    #校验部署参数，不能为空
    if [ -z "$DEPLOY_TARGET_TOMCAT" ]
    then
    echo
    echo 部署参数为空，部署失败！
    echo "#####################################################################"
    exit 1
    fi
    echo
    echo 部署参数：${DEPLOY_TARGET_TOMCAT}
    TOMCAT_ARR=${DEPLOY_TARGET_TOMCAT//;/ }
    ARR=($TOMCAT_ARR)
    ARR_LEN=${#ARR[*]}
    echo 共 ${ARR_LEN} 个部署单元
    i=1
    #获取Jenkins传入的目标TOMCAT组
    for T in $TOMCAT_ARR
    do
    echo
    echo 开始 处理第 ${i} 个部署单元
    echo 第一个部署单元：$T
    #获取目标TOMCAT的WAR路径和TOMCATA的绝对路径
    TOMCAT_PARAM=(${T//:/ })
    MODULE_NAME=${TOMCAT_PARAM[0]}
    TARGET_TOMCAT_PATH=${TOMCAT_PARAM[1]}
    #WAR_PATH="/jenkins/workspace/ysc-all/${MODULE_NAME}/target/*.war"
    WAR_PATH="${WORKSPACE}/${MODULE_NAME}/target/*.war"
    echo 部署单元模块名称："${MODULE_NAME}"
    echo 部署WAR包路径："${WAR_PATH}"
    echo 部署TOMCAT路径："${TARGET_TOMCAT_PATH}"
    #判断IP是否有相关目录
    ssh 172.16.1.35 "[ -d $TARGET_TOMCAT_PATH ]" >/dev/null 2>&1
    if [ $? != 0 ];then
       echo 错误
    else
       echo  正确
    fi
    #校验参数，WORKSPACE变量来自于Jenkins环境变量
    if [ -z "$MODULE_NAME" -o ! -f $WAR_PATH ]
    then
    echo 错误：MAVEN部署模块名称 参数为空 或 找不到WAR包！
    echo 部署失败！
    exit 1
    fi
    #scp 软件包
       ssh $HOST /etc/init.d/${MODULE_NAME} stop
       ssh 172.16.1.35 "[ -d $TARGET_TOMCAT_PATH/webapps/ROOT/ ]" >/dev/null 2>&1
       if [ $? = 0 ];then
      ssh 172.16.1.35 rm -rf $TARGET_TOMCAT_PATH/webapps/ROOT
    if [ $? = 0 ];then
       scp  $WAR_PATH root@172.16.1.35:$TARGET_TOMCAT_PATH/webapps/ROOT.war && echo WAR包部署完毕。
       echo $TARGET_TOMCAT_PATH is OK
    else
       echo 删除$TARGET_TOMCAT_PATH is error
    fi
       else
       echo "not found $TARGET_TOMCAT_PATH/webapps/ROOT"
       scp  $WAR_PATH root@172.16.1.35:$TARGET_TOMCAT_PATH/webapps/ROOT.war && echo WAR包部署完毕。
       ssh $HOST /etc/init.d/${MODULE_NAME} restart
       fi
    ####################启动文件
    done
      #scp /home/config.properties/ysc/${MODULE_NAME}.js root@172.16.1.35:$TARGET_TOMCAT_PATH/webapps/ROOT/web/js/basePath.js
      ssh $HOST /etc/init.d/${MODULE_NAME} restart
    
**Jenkins配置如下修改** 

![](https://i.imgur.com/8tLuZTl.jpg)

![](https://i.imgur.com/fIlJ8TX.png)


**修改完成后我们构建演示** 

![](https://i.imgur.com/cvIAR2i.gif)

提示：这种环境下配置文件都是通过maven build进行控制，也就是通过研发控制配置文件

+ 
+ 
+ 
+

<font size="5">(3) Java 环境演示 [上线脚本]</font><br />
**线上环境演示** 
我们的上线流程如下： 

![](https://i.imgur.com/ipdoWxH.png)

**Jenkins配置如下**： 

![](https://i.imgur.com/Zfb2TjF.png)

![](https://i.imgur.com/6eZokvd.png)

![](https://i.imgur.com/vclPNE9.png)

+ 
+ 
+ 
+ 
+ 
1.首先测试环境脚本：

    [root@tomcat ~]# cat /server/scripts/.upgrade-smscenter.sh
    #!/bin/bash
    WAR="/jenkins/workspace/portal-smscenter/bxg-sms-center-web/target/*.war"
    Path="/data/hub/bxg-smscenter/`date +%Y%m%d`/"
    scp_war(){
    if [ ! -d $Path ];then
    	ssh root@file-server mkdir -p $Path
    scp $WAR root@file-server:$Path
    else
    scp $WAR root@file-server:$Path
    fi
    }
    ssh_file(){
      ssh root@file-server "/bin/bash /server/script/bxg/bxg-smscenter.sh"
    }
    scp_war
    ssh_file

2.跳板机脚本修改

    [root@File-server1 ~]# cat /server/script/bxg/bxg-smscenter.sh
    #!/bin/bash
    HOST=online-server2
    WAR="/data/hub/bxg-smscenter/`date +%Y%m%d`"
    DIR="/application/smscenter/webapps/ROOT/"
    function scp_file {
    if `ssh root@$HOST "[ ! -d $WAR ]"`;then
    ssh root@$HOST "mkdir -p $WAR"
    fi
    scp $WAR/*.war root@$HOST:$WAR/
    echo "scp $WAR/*.war root@$HOST:$WAR/"
    }
    ssh_deploy(){
    ssh root@$HOST "/bin/bash /server/scripts/deploy_smscenter.sh"
    }
    scp_file
    ssh_deploy

3.web 服务器脚本

    [root@online-server2 ~]# cat /server/scripts/deploy_smscenter.sh
    #!/bin/bash
    WAR="/data/hub/bxg-smscenter/`date +%Y%m%d`"
    OBJECT="/application/smscenter/webapps/ROOT/"
    Backup="/data/tomcat/bxg-smscenter-`date +%Y%m%d`"
    SCR_D="/application/smscenter/webapps/ROOT"
    #config="/data/bak"
    backup_tar(){
    tar zcvf $Backup.tar.gz $SCR_D/
    echo "为了防止意外cp整个项目目录存放"
    cp -a $SCR_D/ $Backup
    rm -rf $OBJECT/*
    }
    cp_war(){
    unzip $WAR/*.war -d $SCR_D/
    }
    cp_config(){
    cat $Backup/WEB-INF/classes/application-prod.properties >$SCR_D/WEB-INF/classes/application-prod.properties
    /etc/init.d/smscenter restart
    }
    backup_tar
    cp_war
    cp_config
    [root@online-server2 ~]#

相关文章 [企业必会技能 tomcat](https://www.abcdocker.com/abcdocker/2514)

+ 
+ 
+ 
+

<font size="5">(4) NodeJs 环境演示 [上线脚本]</font><br /> 
**node 环境上线流程** 
Jenkins配置如下 [`node项目不适用maven,所以可以不用创建maven项目,直接在Jenkins创建普通项目就可以`] 

![](https://i.imgur.com/ZAIckxc.png)

![](https://i.imgur.com/EVoI0mn.png)

**1.测试环境脚本**

    [root@tomcat ~]# cat /server/scripts/mobile/mobile.sh
    #!/bin/bash
    source /etc/profile
    HOST=file-server
    BASE_DIR=/server/scripts/mobile/m
    url=$1
    server=$2
    DATE=`date +%Y%m%d`
    tar(){
    rm -rf $BASE_DIR
    [ -d $BASE_DIR ] || mkdir $BASE_DIR
    cd $BASE_DIR
    	echo "##########################################################"
    	echo "代码拉取中！！！"
    	svn co -q $url/ .
    echo "##########################################################"
    }
    cp(){
    cd ${BASE_DIR}
    	/bin/tar -zcvf m_${DATE}.tar.gz ./*
    echo "##########################################################"
    echo "文件已经打包完成！ 正在拷贝中！！！"
    echo "##########################################################"
    sleep 5
    scp  m_${DATE}.tar.gz root@$HOST:/data/hub/bxg-mobile/
    echo "##########################################################"
    echo "文件已经拷贝完成！ 正在上传服务器中！！！"
    echo "##########################################################"
    ssh root@file-server "/bin/bash /server/script/bxg/bxg-mobile.sh $server"
    }
    tar
    cp
    [root@tomcat ~]#

2.跳板机脚本

    [root@File-server1 ~]# cat /server/script/bxg/bxg-mobile.sh
    #!/bin/bash
    HOST=$1
    Mobile_tar="/data/hub/bxg-mobile"
    DIR="/application/node"
    DATE=`date +%Y%m%d`
    scp_file(){
    if `ssh root@$HOST "[ ! -d $Mobile_tar ]"`;then
    ssh root@$HOST "mkdir -p $Mobile_tar"
    fi
    scp $Mobile_tar/m_${DATE}.tar.gz root@$HOST:$DIR/
    sleep 3
    echo "   "
    echo "##########################################################"
    echo "File-server 正在拷贝 ${HOST}！！！"
    sleep 3
    echo "##########################################################"
    }
    ssh_deploy(){
       echo "Hi"
    ssh root@$HOST "/bin/bash /server/scripts/bxg/bxg-mobile.sh"
    }
    scp_file
    ssh_deploy

3.web 发布脚本

    [root@iZbp11tefvghtcfn5mudgdZ ~]# cat /server/scripts/bxg/bxg-mobile.sh
    #!/bin/bash
    source /etc/profile
    DIR="/application/node"
    DATE=`date +%Y%m%d`
    Backup="/application/node/m/"
    BAK="/data/hub/bxg-mobile"
    backup_tar(){
    echo "为了防止意外cp整个项目目录存放"
    cp -ar $Backup ${BAK}/mobile_$DATE
    echo "online-server 原目录拷贝备份完成！"
    }
    cp_war(){
    /etc/init.d/mobile stop
    #mv $Backup /tmp/m_${DATE} && rm -rf /tmp/m_${DATE}
    	rm -rf $Backup
    mkdir $Backup && cd /application/node/
    	tar xf m_${DATE}.tar.gz -C $Backup
    }
    npm_config(){
    cd $Backup
    	cnpm install
    	npm run build-prod
    	npm run start-prod &>/var/log/mobile_${DATE}.log &
    }
    C(){
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++"
    curl  -I 127.0.0.1:3000
    echo "###################################################"
    echo "若是200 服务启动正常！ 可以启动另一台！"
    echo "###################################################"
    }
    backup_tar
    cp_war
    npm_config
    C
+ 
+ 
+ 
相关文章 [Node.js 环境搭建](https://www.abcdocker.com/abcdocker/2840)

总结：Jenkins自动化不是运维一个人就可以完成的,需要研发的参与,本文只是给大家展示一下我公司的自动化,我眼里所谓的自动化. 希望大家不喜勿喷,对文章有意见或建议请在评论留言哦~

转自：[Jenkins 自动化部署上线](https://www.abcdocker.com/abcdocker/3174)

