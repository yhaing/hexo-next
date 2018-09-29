---
title: Zabbix 3.0 生产案例 [四]
date: 2016-11-10 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

# Zabbix 生产案例实战

![](https://i.imgur.com/6pr51X0.png)

## 一、项目规划
### 1、主机分组：
　　　**交换机**
 
　　　**Nginx**
 
　　　**Tomcat**
 
　　　**MySQL**


### 2、监控对象识别：
　　1、使用SNMP监控交换机
 
　　2、使用IPMI监控服务器硬件
 
　　3、使用Agent监控服务器 

　　4、使用JMX监控Java应用
 
　　5、监控MySQL 

　　6、监控Web状态
 
　　7、监控Nginx状态

### 3、操作步骤：
<font size="5">**SNMP监控 **</font><br />

#### 1.1 在交换机上开启`Snmp`

    config t
    snmp-server community public ro
    end
    提示：如果不知道我们可以百度

####1.2 在Zabbix上添加`SNMP监控`
 
　**步骤：**`Configuration--->Hosts--->设置`

![](https://i.imgur.com/kKqjQGX.png) 

#### 1.3 Host页面设置 

![](https://i.imgur.com/C6NOV35.png)

#### 1.4 Templates 模板设置 

![](https://i.imgur.com/3UdruxP.png)

设置SNMP团体名称`Macros宏` 
这里的设置要跟我们创建的`SNMP`的设置相同 

![](https://i.imgur.com/VCchPhs.png)

因为Zabbix监控的时候依赖团体名称 
#### 1.5 生产图片 

![](https://i.imgur.com/uN3BpGJ.png)

　　Zabbix会自动给我们进行检测端口，每个端口都会添加一个网卡的流量图，每个端口都会加上一个触发器。（`端口的状态`） 还会帮我们添加`VLAN`的一个监控 
#### 1.6 案例图 
　　含有有进口和出口流量 

![](https://i.imgur.com/H5nEOIt.jpg)

**提示：**此图是`Zabbix SNMP`模板自动生成的

<font size="5">**IPMI监控 **</font><br />
#### 2.1 添加IPMI 
`Configuration--->Hosts--->选择主机--->设置IPMI端口及主机--->用户名密码`
 
　　因为IMP容易超时，建议使用自定义`item`，本地执行`ipmitool`命令来获取数据

<font size="5">**JMX监控**</font><br /> 
　　Zabbix默认提供了一个监控JMX,通过java gateway来监控java 

![](https://i.imgur.com/PYv7kbp.png)

地址：[https://www.zabbix.com/documentation/3.2/manual/appendix/config/zabbix_java](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.2/manual/appendix/config/zabbix_java) 
　　`JAVA GATEWAY`需要独立安装，相当于一个网关，因为zabbix_server和zabbix-agent不可以直接获取java信息。所以需要一个代理来获取 

![](https://i.imgur.com/KPcj4Q6.jpg)

`zabbix java Gateway`不存任何数据,只是一个简单的代理 

#### 1、安装

    [root@linux-node1 ~]# yum install -y zabbix-java-gateway java-1.8.0
    提示：java-gateway 需要java环境

#### 2、配置 
修改java-gateway

    [root@linux-node1 ~]# vim /etc/zabbix/zabbix_java_gateway.conf 
    # LISTEN_IP="0.0.0.0"   监听的IP地址
    # LISTEN_PORT=10052 监听的端口
    PID_FILE="/var/run/zabbix/zabbix_java.pid" 存放pid路径
    # START_POLLERS=5   开通几个进程,默认是5。你有多少java进行可以设置多少个，也可以设置java进程的一半。
    TIMEOUT=3   超时时间1-30，如果网络环境差，超时时间就修改长一点

我们默认就可以了，不进行修改
 
#### 3、启动

    [root@linux-node1 ~]# systemctl start zabbix-java-gateway.service

#### 4、端口、进程查看 
我们可以进行进程的查看

    [root@linux-node1 ~]# netstat -lntp
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address   Foreign Address State   PID/Program name
    tcp0  0 0.0.0.0:33060.0.0.0:*   LISTEN  10439/mysqld
    tcp0  0 0.0.0.0:80800.0.0.0:*   LISTEN  33484/nginx: master 
    tcp0  0 0.0.0.0:22  0.0.0.0:*   LISTEN  1054/sshd   
    tcp0  0 127.0.0.1:250.0.0.0:*   LISTEN  2484/master 
    tcp0  0 0.0.0.0:10050   0.0.0.0:*   LISTEN  76482/zabbix_agentd 
    tcp0  0 0.0.0.0:10051   0.0.0.0:*   LISTEN  34572/zabbix_server 
    tcp0  0 127.0.0.1:199   0.0.0.0:*   LISTEN  11143/snmpd 
    tcp6   0  0 :::80   :::*LISTEN  10546/httpd 
    tcp6   0  0 :::22   :::*LISTEN  1054/sshd   
    tcp6   0  0 ::1:25  :::*LISTEN  2484/master 
    tcp6   0  0 :::10050:::*LISTEN  76482/zabbix_agentd 
    tcp6   0  0 :::10051:::*LISTEN  34572/zabbix_server 
    tcp6   0  0 :::10052:::*LISTEN  13465/java 
    
`10052` `zabbix-java-gateway`默认端口已经起来了！ 
　　它是一个java应用，需要安装jdk

    [root@linux-node1 ~]# ps -aux|grep java
    root  13465  0.4  3.4 2248944 34060 ?   Sl   19:17   0:01 java -server -Dlogback.configurationFile=/etc/zabbix/zabbix_java_gateway_logback.xml -classpath lib:lib/android-json-4.3_r3.1.jar:lib/logback-classic-0.9.27.jar:lib/logback-core-0.9.27.jar:lib/slf4j-api-1.6.1.jar:bin/zabbix-java-gateway-3.0.4.jar -Dzabbix.pidFile=/var/run/zabbix/zabbix_java.pid -Dzabbix.timeout=3 -Dsun.rmi.transport.tcp.responseTimeout=3000 com.zabbix.gateway.JavaGateway
    root  13584  0.0  0.0 112648   972 pts/0S+   19:21   0:00 grep --color=auto java

#### 5、通知zabbix-server 
　　我们需要通知`zabbix-server`，`java-gateway`在哪里 
修改配置文件

    [root@linux-node1 ~]# vim /etc/zabbix/zabbix_server.conf 
    编辑zabbix-server来指定zabbix-java-gateway
    JavaGateway=192.168.56.11 #IP地址是安装java-gateway的服务器
    # JavaGatewayPort=10052   端口，默认就可以
    StartVMwareCollectors=5 预启动多少个进程[zabbix--->java-gateway的数量]

#### 6、重启zabbix-server

    [root@linux-node1 ~]# systemctl restart zabbix-server.service 

#### 7、准备apache 
我们安装tomcat-8版本 
官网：`http://tomcat.apache.org` 
下载软件包

    [root@linux-node2 src]# wget http://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.5/bin/apache-tomcat-8.5.5.tar.gz

我们将tomcat安装在apache服务器上，来模拟监控jvm

    [root@linux-node2 src]# tar xf apache-tomcat-8.5.5.tar.gz 
    [root@linux-node2 src]# mv apache-tomcat-8.5.5 /usr/local/
    [root@linux-node2 src]# ln -s /usr/local/apache-tomcat-8.5.5/ /usr/local/tomcat
    [root@linux-node2 src]# yum install -y java-1.8.0#tomcat 需要在java环境运行
    [root@linux-node2 src]# /usr/local/tomcat/bin/startup.sh 
    Using CATALINA_BASE:   /usr/local/tomcat
    Using CATALINA_HOME:   /usr/local/tomcat
    Using CATALINA_TMPDIR: /usr/local/tomcat/temp
    Using JRE_HOME:/usr
    Using CLASSPATH:   /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
    Tomcat started.

在web2上面查看运行状态

    [root@linux-node2 src]# netstat -lntup
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address   Foreign Address State   PID/Program name
    tcp0  0 0.0.0.0:22  0.0.0.0:*   LISTEN  1073/sshd   
    tcp0  0 127.0.0.1:250.0.0.0:*   LISTEN  2498/master 
    tcp0  0 0.0.0.0:10050   0.0.0.0:*   LISTEN  10088/zabbix_agentd 
    tcp6   0  0 :::8080 :::*LISTEN  25750/java  
    tcp6   0  0 :::22   :::*LISTEN  1073/sshd   
    tcp6   0  0 ::1:25  :::*LISTEN  2498/master 
    tcp6   0  0 :::10050:::*LISTEN  10088/zabbix_agentd 
    tcp6   0  0 127.0.0.1:8005  :::*LISTEN  25750/java  
    tcp6   0  0 :::8009 :::*LISTEN  25750/java
  
![](https://i.imgur.com/1OprelT.png)

**JMX三种类型：**
 
　　1.无密码认证
 
　　2.用户面密码认证
 
　　3.ssl

开启JMX远程监控 
官方文档：[http://tomcat.apache.org/tomcat-8.0-doc/monitoring.html](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://tomcat.apache.org/tomcat-8.0-doc/monitoring.html) 
我们创建一个无密码认证

    [root@linux-node2 src]# vim /usr/local/tomcat/bin/catalina.sh 
     CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote
      -Dcom.sun.management.jmxremote.port=8888   　　　#端口号 
      -Dcom.sun.management.jmxremote.ssl=false　　　　　#SSL 关闭
      -Dcom.sun.management.jmxremote.authenticate=false  #用户密码验证关闭
      -Djava.rmi.server.hostname=192.168.56.12" 　　　　　　 #监控的主机

修改完成后重启`tomcat` 
可以使用`./shutdown.sh` 或者使用`kill`的方式

    [root@linux-node2 src]# /usr/local/tomcat/bin/shutdown.sh 
    Using CATALINA_BASE:   /usr/local/tomcat
    Using CATALINA_HOME:   /usr/local/tomcat
    Using CATALINA_TMPDIR: /usr/local/tomcat/temp
    Using JRE_HOME:/usr
    Using CLASSPATH:   /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
    中间可以使用px -aux|grep java  查看是否被杀死
    [root@linux-node2 src]# /usr/local/tomcat/bin/startup.sh 
    Using CATALINA_BASE:   /usr/local/tomcat
    Using CATALINA_HOME:   /usr/local/tomcat
    Using CATALINA_TMPDIR: /usr/local/tomcat/temp
    Using JRE_HOME:/usr
    Using CLASSPATH:   /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
    Tomcat started.
    
我们JMX端口设置为8888

    [root@linux-node2 src]# netstat -lntup
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address   Foreign Address State   PID/Program name
    tcp0  0 0.0.0.0:22  0.0.0.0:*   LISTEN  1073/sshd   
    tcp0  0 127.0.0.1:250.0.0.0:*   LISTEN  2498/master 
    tcp0  0 0.0.0.0:10050   0.0.0.0:*   LISTEN  10088/zabbix_agentd 
    tcp6   0  0 :::8080 :::*LISTEN  26226/java  
    tcp6   0  0 :::22   :::*LISTEN  1073/sshd   
    tcp6   0  0 :::8888 :::*LISTEN  26226/java  
    tcp6   0  0 ::1:25  :::*LISTEN  2498/master 
    tcp6   0  0 :::10050:::*LISTEN  10088/zabbix_agentd 
    tcp6   0  0 :::38532:::*LISTEN  26226/java  
    tcp6   0  0 127.0.0.1:8005  :::*LISTEN  26226/java  
    tcp6   0  0 :::8009 :::*LISTEN  26226/java  
    tcp6   0  0 :::38377:::*LISTEN  26226/java 
  
　我们可以在windows上面安装jdk ，使用命令行来监控java 

![](https://i.imgur.com/KTDLwjl.png)

　　我们下载安装，具体步骤不说了，然后我们找到`jconsole.exe`文件运行 

![](https://i.imgur.com/aFSUY6W.png)

填写安装JMX的服务器 

![](https://i.imgur.com/C45mLsm.png)

　　因为在配置文件中我们设置的是无密码认证，所以这里不需要输入密码直接连接。端口号我们设置的是8888连接即可 

![](https://i.imgur.com/FTJLyGS.png)

这样我们就可以在图形化监控tomcat 

![](https://i.imgur.com/yIebcSQ.png)

　　提示：按照现在观察，java-gateway已经安装成功，我们可以加入到zabbix中 
　　找我们要添加的主机 

![](https://i.imgur.com/4aNTxLt.png)

填写安装java-gateway的主机 

![](https://i.imgur.com/2VFkrmj.png)

我们还需要设置一个模板 

![](https://i.imgur.com/dlWc3pZ.png)

这个模板就是我们自带的一个监控`JMX`的模板，然后我们点击`Update`.更新 

![](https://i.imgur.com/AsK1f7o.png)

我们需要等待一会才可以出图

提示：可以在Zabbix-server上使用zabbix-get获取某一台机器的某一个key ,效果图如下：需要等待一会 

![](https://i.imgur.com/ws9fze3.png)

**手动检测监控状态 **
Zabbix-Server操作：

    [root@linux-node1 ~]# yum install -y zabbix-get

**Key： **

![](https://i.imgur.com/oO9IuKb.png)

我们随便找一个key，然后我们复制后面的key


![](https://i.imgur.com/h2pUmF6.png)

    [root@linux-node1 ~]# zabbix_get -s 192.168.56.12 -k jmx["java.lang:type=Runtime",Uptime]
    ZBX_NOTSUPPORTED: Unsupported item key.

提示：未支持的key，现在并不能获取到这个key 因为没有获取到这个值，所以不会显示。我们可以获取别的试一下

    [root@linux-node1 ~]# zabbix_get -s 192.168.56.12 -k system.cpu.util[,user]
    0.079323
    [root@linux-node1 ~]# zabbix_get -s 192.168.56.12 -k system.cpu.util[,user]
    0.075377
    [root@linux-node1 ~]# zabbix_get -s 192.168.56.12 -k system.cpu.util[,user]
    0.075377
    [root@linux-node1 ~]# zabbix_get -s 192.168.56.12 -k system.cpu.util[,user]
    0.073547

小结： Zabbix其实就是通过zabbix_get 获取到的这个值进行比较的

### 日志

开启zabbix debug模式

    [root@linux-node2 tomcat]# systemctl restart zabbix-agent
    ### Option: DebugLevel
    #   Specifies debug level:
    #   0 - basic information about starting and stopping of Zabbix processes
    #   1 - critical information
    #   2 - error information
    #   3 - warnings
    #   4 - for debugging (produces lots of information)
    #   5 - extended debugging (produces even more information)
    DebugLevel=4

如果及别是`4`就是`debug`模式，修改完配置文件之后需要重启生效

## Zabbix生产案例

**1.开启Nginx监控**
 
**2.编写脚本来进行数据采集**
 
**3.设置用户自定义参数**

**4.重启zabbix-agent**
 
**5.添加item**
 
**6.创建图形**

**7.创建触发器**

**8.创建模板**

### 实践步骤

1. 脚本编写： 我们这里提供已经写好的脚本,链接：[https://pan.baidu.com/s/19JrCetaRZYGY_mvq4CyoJQ](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://pan.baidu.com/s/19JrCetaRZYGY_mvq4CyoJQ) 密码：94us

2. 需要修改一下`zabbix-agent`的配置文件

    vim /etc/zabbix/zabbix_agentd.conf
    
    修改Include设置,这样我们可以把脚本放在这个目录下。配置就是.conf结尾
    Include=/etc/zabbix/zabbix_agentd.d/*.conf


3.添加权限及测试脚本

    [root@linux-node1 zabbix_agentd.d]# chmod +x zabbix_linux_plugin.sh 
    [root@linux-node1 zabbix_agentd.d]# sh zabbix_linux_plugin.sh 
    Usage: zabbix_linux_plugin.sh {tcp_status key|memcached_status key|redis_status key|nginx_status key}

**提示：** 这个脚本要用`zabbix`用户执行的权限，因为都是`zabbix`用户在执行，监控`TCP`会在`/tmp/`目录生成一个文件用于监控使用

4.修改nginx配置文件

    提示：nginx 默认路径是/usr/local/nginx  编译安装需要查看安装路径
    [root@linux-node1 zabbix_agentd.d]# vim /usr/local/nginx/conf/nginx.conf
    location /nginx_status {
    stub_status on;
    allow 127.0.0.1;
    access_log off;
    }

因为脚本的url是nginx_status所以我们配置文件也要这样修改 
　　测试脚本

    [root@linux-node1 zabbix_agentd.d]# curl 192.168.56.11:8080/nginx_status
    Active connections: 1 
    server accepts handled requests
     2823682 2823682 2821835 
    Reading: 0 Writing: 1 Waiting: 0 
    [root@linux-node1 zabbix_agentd.d]# ./zabbix_linux_plugin.sh nginx_status 8080 active
    1
    [root@linux-node1 zabbix_agentd.d]# ./zabbix_linux_plugin.sh nginx_status 8080 reading
    0
    [root@linux-node1 zabbix_agentd.d]# ./zabbix_linux_plugin.sh nginx_status 8080 handled
    2823688

设置`Key`，首先是`Key`的名称

    [root@linux-node1 zabbix_agentd.d]# cat linux.conf
    UserParameter=linux_status[*],/etc/zabbix/zabbix_agentd.d/zabbix_linux_plugin.sh "$1" "$2" "$3"
    [*]代表一个传参，可以将后面的$1,$2,$3引入进行
    ，后面是脚步本的路径

需要重启agent

    [root@linux-node1 zabbix_agentd.d]# systemctl restart zabbix-agent

我们使用zabbix_get进行测试

    [root@linux-node1 zabbix_agentd.d]# zabbix_get -s 192.168.56.11 -k linux_status[nginx_status,8080,active]
    1
    [-k] 就是指定key 不细说了
    [*] *的作用在web界面配置item会显示出来

5.Zabbix web界面设置 
　　我们需要添加item，因为要加好多。我们就使用模板的方式进行添加 

![](https://i.imgur.com/YRsdoDe.png)

![](https://i.imgur.com/6Qcq22z.png)

![](https://i.imgur.com/CVXUYq5.png)

**提示：**我们写一下注释然后选择Add即可 
找到我们的模板 

![](https://i.imgur.com/JTAqZ3l.png)

我们创建item 

![](https://i.imgur.com/qHWxb3y.png)

创建 

![](https://i.imgur.com/czEMS6G.png)

各参数前文都有讲解不细说！ 
　修改完成吼点击Add 

![](https://i.imgur.com/DZkOJ0b.png)

　　添加完成后我们要复制很多个用来监控Nginx status的所有状态，所以我们使用克隆。来克隆多个进行设置 

![](https://i.imgur.com/dbJPEHV.png)

点进我们的item，然后拖到最下面选择克隆 

![](https://i.imgur.com/XEAZnA9.png)

填一些基本的修改即可，例如下： 

![](https://i.imgur.com/Chpvp2n.png)

添加完成如下图： 

![](https://i.imgur.com/vloLofW.png)

item添加完成我们还需要添加一个图形，用于展示，找到图形路径。点击创建 

![](https://i.imgur.com/7SVM9c5.png)

![](https://i.imgur.com/QSDVSUj.png)

因为我们主机还没有加入我们的模板，所以我们这里是没有数据的 

![](https://i.imgur.com/4Ay1ui5.png)

下面将模板加入到主机中 

![](https://i.imgur.com/PIDSj6i.png)

修改模板 

![](https://i.imgur.com/xlaECqY.png)

查看结果如下： 

![](https://i.imgur.com/NSRWpYw.png)

6.导出模板 
因为设置模板比较麻烦，我们可以将模板导出

![](https://i.imgur.com/lHmOsxR.png)

导出之后我们需要修改名称就可以了

7.导入模板 
我们需要导出自然需要导入，操作如下： 

![](https://i.imgur.com/aRtpEdy.png)

点击添加即可 

![](https://i.imgur.com/XAVcnh8.png)

**提示：** 模板之间的名称不可以相同

## 以上就是Nginx完整的监控使用
8.导入TCP模板 

　　加入模板的步骤跟刚刚加入`Nginx`的一样，这里我们就使用模板了。 
下载链接：[http://pan.baidu.com/s/1i54ULjJ](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://pan.baidu.com/s/1i54ULjJ) 密码：25lh 
我们导入模板即可 

![](https://i.imgur.com/kayMTTF.png)

导入完成之后我们可以查看模板 

![](https://i.imgur.com/UUXBuLW.png)

　　在里面我们可以见到TCP的11种状态，这个`item`是我们需要根据我们脚本进行同步的。 

![](https://i.imgur.com/OB5aqaE.png)

我们可以随便点击一个进行查看，其中这里的key要和脚本的相同 

![](https://i.imgur.com/9qzH8co.png)

![](https://i.imgur.com/bjsZ6fj.png)

我们在两台服务器都加载这个模板 

![](https://i.imgur.com/LlItymc.png)

步骤和上面的一样 

![](https://i.imgur.com/tVdvWa3.png)

添加完成 

![](https://i.imgur.com/PYJTQlW.png)

　　查看脚本需要等待1分钟，这主要看我们设置的获取值的时间而定。 
我们可以查看图形 

![](https://i.imgur.com/F6Yr1bH.png)


更多内容请看下集！~

转载自：[Zabbix 3.0 生产案例 [四]](https://www.abcdocker.com/abcdocker/1471)
