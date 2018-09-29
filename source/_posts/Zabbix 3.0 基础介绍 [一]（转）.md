---
title: Zabbix 3.0 基础介绍 [一]
date: 2016-10-10 09:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---
![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

### 摘要

本文主要讲述Zabbix的简介以及Zabbix安装及页面设置

## Zabbix 3.0 基础介绍 [一]

### 一、Zabbix介绍
zabbix 简介
>   Zabbix 是一个高度集成的网络监控解决方案，可以提供企业级的开源分布式监控解决方案，由一个国外的团队持续维护更新，软件可以自由下载使用，运作团队靠提供收费的技术支持赢利
>   zabbix是一个基于Web界面的，提供分布式系统监控以及网络监视功能的企业级的开源解决方案。
>   zabbix能监视各种网络参数，保证服务器系统的安全运营，并提供灵活的通知机制以让系统管理员快速定位/解决存在的各种问题
<!--more-->
>   zabbix主要由2部分构成zabbix server和zabbix agent，可选组建zabbix proxy
>   zabbix server可以通过SNMP，zabbix agent，fping端口监视等方法对远程服务器或网络状态完成监视，数据收集等功能。同时支持Linux以及Unix平台，Windows平台只能安装客户端

<font size="6">**Zabbix功能**</font><br />

　　①具备常见的商业监控软件所具备的功能（主机的性能监控、网络设备性能监控、数据库、性能监控、FTP 等通用协议监控、多种告警方式、详细的报表图表绘制）

　　②支持自动发现网络设备和服务器（可以通过配置自动发现服务器规则来实现）

　　③支持自动发现（low discovery）key 实现动态监控项的批量监控（需写脚本）

　　④支持分布式，能集中展示、管理分布式的监控点

　　⑤扩展性强，server 提供通用接口（api 功能），可以自己开发完善各类监控（根据相关接口编写程序实现）编写插件容易，可以自定义监控项，报警级别的设置。

　　⑥数据收集
　可用和性能检测

　支持snmp(包括trapping and polling)，IPMI，JMX，SSH，TELNET

　自定义的检测

　自定义收集数据的频率

　服务器/代理和客户端模式

　灵活的触发器

　可以定义非常灵活的问题阈值，称为触发器，从后端数据库的参考值

　高可定制的报警

　发送通知，可定制的报警升级，收件人，媒体类型

　通知可以使用宏变量有用的变量

　自动操作包括远程命令

　实时的绘图功能

　监控项实时的将数据绘制在图形上面

　WEB 监控能力

　ZABBIX 可以模拟鼠标点击了一个网站，并检查返回值和响应时间

### Api 功能
　　应用api功能，可以方便的和其他系统结合，包括手机客户端的使用。
更多功能请查看
[http://www.zabbix.com/documentation.php](http://www.zabbix.com/documentation.php)


<font size="6">**Zabbix版本**</font><br />

**Zabbix 3.0 Manual**

**Zabbix 2.4 Manual**

**Zabbix 2.2 Manual**

**Zabbix 2.0 Manual**

下载地址：[http://www.zabbix.com/documentation.php](http://www.zabbix.com/documentation.php)

本次采用yum安装，安装zabbix3.0.使用Centos7

<font size="6">**Zabbix优缺点**</font><br />

**优点**

　1、开源，无软件成本投入

　2、Server 对设备性能要求低

　3、支持设备多，自带多种监控模板

　4、支持分布式集中管理，有自动发现功能，可以实现自动化监控

　5、开放式接口，扩展性强，插件编写容易

　6、当监控的item 比较多服务器队列比较大时可以采用被动状态，被监控客户端主动从

　7、server 端去下载需要监控的item 然后取数据上传到server 端。这种方式对服务器的负载比较小。

　8、Api 的支持，方便与其他系统结合

**缺点**

　　需在被监控主机上安装agent，所有数据都存在数据库里，产生的数据据很大,瓶颈主要在数据库。

<font size="6">**Zabbix监控原理**</font><br />

Zabbix 通过C/S 模式采集数据，通过B/S模式在web 端展示和配置。

**被监控端：**主机通过安装agent 方式采集数据，网络设备通过SNMP 方式采集数据

**Server 端**：通过收集SNMP 和agent 发送的数据，写入数据库（MySQL，ORACLE 等），再通过php+apache 在web 前端展示。

<font size="6">**Zabbix运行条件**</font><br />

`Server：`Zabbix Server 需运行在LAMP（Linux+Apache+Mysql+PHP）环境下（或者LNMP），对硬件要求低

`Agent：`目前已有的agent 基本支持市面常见的OS，包含Linux、HPUX、Solaris、Sun、
windows

`SNMP：`支持各类常见的网络设备
SNMP(Simple Network Management Protocol,简单网络管理协议

Zabbix监控过程逻辑图

![](https://i.imgur.com/M9pzlrg.png)

<font size="6">**Zabbix监控类型**</font><br />

**硬件监控：**适用于物理机、远程管理卡（iDRAC），IPMI（只能平台管理接口）

**ipmitools:**MegaCli（查看Raid磁盘）

**系统监控: **监控cpt：lscpu、uptime、top、vmstat 1 、mpstat 1、htop

**监控内存：** free -m

**监控硬盘：**df -h、iotop

**监控网络：**iftop、netstat、ss

**应用服务监控：**nfs、MySQL、nginx、apache、php、rsync

更详细的监控类型可以参考：[http://www.abcdocker.com/abcdocker/1376](http://www.abcdocker.com/abcdocker/1376)


<font size="6">**引入Zabbix**</font><br />
所有监控范畴，都可以整合到Zabbix中

　　　`硬件监控`：Zabbix、IPMI、lnterface

　　　`系统监控`：Zabbix、Agent、Interface

　　　`Java监控`：Zabbix、JMX、lnterface

　　　`网络设备监控`：Zabbix、SNMP、lnterface

　　　`应用服务监控`：Zabbix、Agent、UserParameter

　　　`MySQL数据库监控`：percona-monitoring-plulgins

　　　`URL监控`：Zabbix Web监控

##二、Zabbix 环境配置

1、环境信息

    [root@localhost ~]# cat /etc/redhat-release 
    CentOS Linux release 7.2.1511 (Core) 
    [root@localhost ~]# uname -r
    3.10.0-327.28.3.el7.x86_64

2、yum安装
阿里云yum源已经提供了zabbix3.0，因此我们需要使用官方yum源。官方yum源下载会比较慢

    [root@localhost ~]# rpm -ivh http://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm

问题：为什么要下载release版本的zabbix？

    [root@localhost ~]# ls /etc/yum.repos.d/
    CentOS-Base.repo       CentOS-Media.repo    epel.repo.rpmnew
    CentOS-CR.repo         CentOS-Sources.repo  epel-testing.repo
    CentOS-Debuginfo.repo  CentOS-Vault.repo    zabbix.repo
    CentOS-fasttrack.repo  epel.repo

因为下载这个版本会在yum.repos.d下面生成一个zabbix.repo的文件

3、安装相关软件包

    [root@localhost ~]# yum install zabbix-server zabbix-web zabbix-server-mysql zabbix-web-mysql mariadb-server mariadb -y
    注：如果Server端也需要监控则需要安装zabbix-agent

提示：在Centos7中，mysql改名为mariadb

4、修改PHP时区设置

    [root@localhost ~]# sed -i 's@# php_value date.timezone Europe/Riga@php_value date.timezone Asia/Shanghai@g' /etc/httpd/conf.d/zabbix.conf
    #要注意需要改的配置文件是/etc/httpd/conf.d/zabbix.conf而不是/etc/php.ini，

## 三、数据库设置

1.启动数据库

    [root@localhost ~]# systemctl start mariadb

2.创建zabbix数据库及用户

    mysql
    create database zabbix character set utf8 collate utf8_bin;
    grant all on zabbix.* to zabbix@'localhost' identified by '123456';
    exit

3.导入数据

    [root@localhost ~]# cd /usr/share/doc/zabbix-server-mysql-3.0.4/
    [root@localhost zabbix-server-mysql-3.0.4]# ll
    total 1836
    -rw-r--r-- 1 root root      98 Jul 22 11:05 AUTHORS
    -rw-r--r-- 1 root root  687803 Jul 22 11:05 ChangeLog
    -rw-r--r-- 1 root root   17990 Jul 22 11:06 COPYING
    -rw-r--r-- 1 root root 1158948 Jul 24 02:59 create.sql.gz
    -rw-r--r-- 1 root root      52 Jul 22 11:06 NEWS
    -rw-r--r-- 1 root root     188 Jul 22 11:05 README
    [root@localhost zabbix-server-mysql-3.0.4]# zcat create.sql.gz |mysql -uzabbix -p123456 zabbix

我们使用zcat，专门查看sql.gz包。和cat基本相似

4.修改zabbix配置文件

    [root@localhost zabbix-server-mysql-3.0.4]# vim /etc/zabbix/zabbix_server.conf 
    DBHost=localhost    #数据库所在主机
    DBName=zabbix       #数据库名
    DBUser=zabbix       #数据库用户
    DBPassword=123456   #数据库密码 

5.启动zabbix及apache

    [root@localhost ~]# systemctl start zabbix-server
    [root@localhost ~]# systemctl start httpd
    注意：如果没有启动成功，要看一下是不是80端口被占用

6.Web界面安装master
访问地址：http://192.168.56.11/zabbix/setup.php

![](https://i.imgur.com/Y0FbhLO.png)


点击Next step进行安装

![](https://i.imgur.com/dpTGdps.png)

首先要确保没有`no`，如果时区没有改好会提示我们进行修改

![](https://i.imgur.com/KImKUyY.png)

账号密码都是我们刚刚在配置文件中设置的，端口默认就是3306

![](https://i.imgur.com/zqFISGd.png)

为我们的zabbix起个名字，一会在右上角会显示

![](https://i.imgur.com/lbEzQgq.png)

最后是展示我们的配置信息，可以查看到哪里有错误

![](https://i.imgur.com/D6OBpnl.png)

点击Finish

![](https://i.imgur.com/Hoy4rE4.png)

![](https://i.imgur.com/qNhEqTT.png)

**提示：登录上去之后请立即修改密码**

7.配置zabbix-agent端

    [root@localhost ~]# vim /etc/zabbix/zabbix_agentd.conf 
    Server=127.0.0.1       修改Server端的IP地址（被动模式IP地址）
    ServerActive=127.0.0.1     主动模式，主动向server端报告
    [root@localhost ~]# systemctl start zabbix-agent

查看端口号

    [root@localhost ~]# netstat -lntp
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
    tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      7806/mysqld         
    tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1062/sshd           
    tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      2208/master         
    tcp        0      0 0.0.0.0:10050           0.0.0.0:*               LISTEN      11511/zabbix_agentd 
    tcp        0      0 0.0.0.0:10051           0.0.0.0:*               LISTEN      11335/zabbix_server 
    tcp        0      0 127.0.0.1:199           0.0.0.0:*               LISTEN      2692/snmpd          
    tcp6       0      0 :::80                   :::*                    LISTEN      11408/httpd         
    tcp6       0      0 :::22                   :::*                    LISTEN      1062/sshd           
    tcp6       0      0 ::1:25                  :::*                    LISTEN      2208/master         
    tcp6       0      0 :::443                  :::*                    LISTEN      11408/httpd         
    tcp6       0      0 :::10050                :::*                    LISTEN      11511/zabbix_agentd 
    tcp6       0      0 :::10051                :::*                    LISTEN      11335/zabbix_server 
    10051为server端口，10050为agent端口

## 四、Web界面配置

找到Configuration---->Hosts 添加一台监控主机

![](https://i.imgur.com/OQtdGC7.png)


![](https://i.imgur.com/4sqRwZA.png)


开启后，如果出现错误我们可以看一下zabbix的日志

    [root@localhost ~]# ls /var/log/zabbix/zabbix_
    zabbix_agentd.log  zabbix_server.log  

![](https://i.imgur.com/Dyhcngl.png)

当ZBX变成绿色的时候，说明监控成功。因为我们没有配置SNMP、JMX、IPMI等。所以我发监控

![](https://i.imgur.com/v8exaM1.png)

因为我们现在只安装了一台服务器，所以只有一个主机。我们可以查看现在这台主机的CPU等及基本的信息

![](https://i.imgur.com/SwyQSOk.png)

点击Monitoring-----Graphs，选择我们要监控的内容


![](https://i.imgur.com/NmVuFzW.png)


我们选择可以随便选择一个进行查看信息

**例如：我们查看CPU的负载**

![](https://i.imgur.com/1elSO7z.png)

　　某一段时间内，CPU正在处理以及等待CPU处理的进程数的之和。Load Average是从另一个角度来体现CPU的使用状态的。
　　这些监控其实就是zabbix在数据库查找数据，然后使用jd进行画图
Zabbix性能依赖于mysql数据库

## 五、Zabbix页面安全设置

1、设置默认账号密码

![](https://i.imgur.com/IsMI8p3.png)

![](https://i.imgur.com/eubPtYz.png)

　　设置完中文

![](https://i.imgur.com/lzewi1o.png)

## 六、Zabbix 菜单说明

Zabbix 上方的菜单简单介绍说明

![](https://i.imgur.com/5POkJOH.png)

Doshboard下面可以设置你想设置的图形，添加方法如下：

![](https://i.imgur.com/iZGn6s7.png)

![](https://i.imgur.com/Zt1fKW8.png)

　　这时，就可以找到你喜爱的了，直接打开

![](https://i.imgur.com/8TZAkjv.png)

screens其实就是一个聚合图形，可以把多个图片合在一起。然后放在大屏幕上，供别人查看

![](https://i.imgur.com/STjX7B8.png)

maps就是一个架构图

![](https://i.imgur.com/eDcuFPV.png)

Status of Zabbix就是一个状态栏

![](https://i.imgur.com/o4i3rN2.png)

　第一行是Server是否运行[yes]和后面的运行地址
　第二行监控的机器 （启用的/关闭的/模板）
　第三行监控项 （启用的/关闭的/不支持的）
　第四行触发器的状态 （启用的/关闭的/【故障/正常】）
　第五行 当前用户数量 （在线数量）
　第六行 zabbix每秒可以收到的一个新值

告警的级别

![](https://i.imgur.com/sz37Fh0.png)

我们可以设置报警响铃，让他在前端响

![](https://i.imgur.com/clGNaeB.png)


![](https://i.imgur.com/pyyrI8b.png)

我们首页的监控列表是可以随意拖动的

![](https://i.imgur.com/x89VF1o.png)

我们还可以将它关闭，并且设置刷新时间

![](https://i.imgur.com/mKtz4Hj.png)


Zabbix 基础完!

转载自：[Zabbix 3.0 基础介绍 [一] | abcdocker运维博客](https://www.abcdocker.com/abcdocker/1402)