---
title: Zabbix 3.0 分布式监控 [九]
date: 2016-11-21 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->
   `Zabbix Proxy`是一个类似于代理的服务，可以代替`Zabbix-server`获取 `zabbix-agent`信息。其中`数据`存到本地（Proxy有自己的数据库）然后在发送给Server，这样可以保证数据不丢失 
　　`Zabbix-server ----->Zabbix-Proxy ----->Zabbix-Server` 

![](https://i.imgur.com/Om7x5k9.png)

地址：[https://www.zabbix.com/documentation/3.0/manual/distributed_monitoring/proxies](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/distributed_monitoring/proxies)

## Zabbix Proxy 使用场景

　　常用于多机房情况或者监控主机特别多，几千台左右。这时候使用`Zabbix Proxy` 可以减轻服务器`server`的压力，还可以减轻Zabbix的维护。 
　　最常用的特点是适用于`多机房`、`网络不稳定`的时候，因为如果直接由Zabbix-server发送信息可能agent没有收到，但是直接使用`Zabbix-Proxy`就不会遇到这个问题。
 　 
### Zabbix官方说明（分布式监控）
 
Proxy 有如下功能 

![](https://i.imgur.com/ndd3EzV.png)

地址： [Distributed monitoring](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/distributed_monitoring)
 
**NO - 中文解释**

1.没有Web界面
 
2.本身不做任何告警通知（告警通知都是Server做）

**小结：** 
　　`Zabbix Proxy` 可以有多个，用来代理`Zabbix server`来运行。`Proxy`会将所有数据暂存于本地,然后同一转发到Zabbix Server上 
　　Proxy只需要一条TCP链接，可以连接到Zabbix-server上即可。所以防火墙只需要添加一条Zabbix Proxy即可 我们可以参考上面的`Zabbix Proxy图` 
　　Proxy是需要使用单独的`数据库`，所以不能将`Server`和`Agent`放在一起 
**Proxy说明：**[https://www.zabbix.com/documentation/3.0/manual/distributed_monitoring/proxies](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/distributed_monitoring/proxies) 
**安装文档：**[https://www.zabbix.com/documentation/3.0/manual/installation/install](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/installation/install) 
　官方文档使用的是源码安装，因为方便我们使用yum安装，因为我们只有2台，所以就用agent当做Proxy

    [root@linux-node2 ~]# yum install -y zabbix-proxy zabbix-proxy-mysql mariadb-server
    我们需要启动MySQL
    [root@linux-node2 ~]# systemctl start mariadb.service 

我们还需要创建一个库

    mysql
    create database zabbix_proxy character set utf8;
    grant all on zabbix_proxy.* to zabbix_proxy@localhost identified by 'zabbix_proxy';

我们需要导入数据

    [root@linux-node2 ~]# cd /usr/share/doc/zabbix-proxy-mysql-3.0.5/
    [root@linux-node2 zabbix-proxy-mysql-3.0.5]# zcat schema.sql.gz | mysql -uzabbix_proxy -p zabbix_proxy
    Enter password: 
    #密码是：zabbix_proxy 是我们数据库授权的密码

检查数据库

    mysql
    show databases;
    use zabbix_proxy;
    show tables;
    #查看是否含有数据

我们需要修改proxy的配置文件

    [root@linux-node2 zabbix-proxy-mysql-3.0.5]# vim /etc/zabbix/zabbix_proxy.conf 
    Server=192.168.56.11
    Hostname=Zabbix proxy
    DBName=zabbix_proxy
    #数据库名称
    DBUser=zabbix_proxy
    #用户名
    DBPassword=zabbix_proxy
    #用户密码
    配置文件中没有配置的内容如下：（有需要可以配置）
    # ProxyLocalBuffer=0
    #数据保留的时间（小时为单位）
    # ProxyOfflineBuffer=1
    #连不上Server，数据要保留多久（小时为单位，默认1小时）
    # DataSenderFrequency=1
    #数据的发送时间间隔（默认是1秒）
    # StartPollers=5
    #启动的线程数
    # StartIPMIPollers=0
    #启动IPMI的线程数
    从这往下都是性能的监控，就不一次说明了。 上面都有中文注释

过滤修改过的配置如下：
    
    [root@linux-node2 zabbix-proxy-mysql-3.0.5]# grep '^[a-Z]' /etc/zabbix/zabbix_proxy.conf
    Server=192.168.56.11
    Hostname=Zabbix proxy
    LogFile=/var/log/zabbix/zabbix_proxy.log
    LogFileSize=0
    PidFile=/var/run/zabbix/zabbix_proxy.pid
    DBName=zabbix_proxy
    DBUser=zabbix_proxy
    DBPassword=zabbix_proxy
    SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
    Timeout=4
    ExternalScripts=/usr/lib/zabbix/externalscripts
    LogSlowQueries=3000

启动

    [root@linux-node2 ~]# systemctl start zabbix-proxy

查看proxy进程

    [root@linux-node2 ~]# netstat -lntup
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address   Foreign Address State   PID/Program name
    tcp0  0 0.0.0.0:33060.0.0.0:*   LISTEN  15685/mysqld
    tcp0  0 0.0.0.0:22  0.0.0.0:*   LISTEN  1073/sshd   
    tcp0  0 127.0.0.1:250.0.0.0:*   LISTEN  2498/master 
    tcp0  0 0.0.0.0:10051   0.0.0.0:*   LISTEN  15924/zabbix_proxy  
    tcp6   0  0 :::44589:::*LISTEN  9052/java   
    tcp6   0  0 :::8080 :::*LISTEN  9052/java   
    tcp6   0  0 :::22   :::*LISTEN  1073/sshd   
    tcp6   0  0 :::8888 :::*LISTEN  9052/java   
    tcp6   0  0 ::1:25  :::*LISTEN  2498/master 
    tcp6   0  0 :::39743:::*LISTEN  9052/java   
    tcp6   0  0 :::10051:::*LISTEN  15924/zabbix_proxy  
    tcp6   0  0 127.0.0.1:8005  :::*LISTEN  9052/java   
    tcp6   0  0 :::8009 :::*LISTEN  9052/java 

**Zabbix-proxy 监控10051端口，因为是代理就必须跟Server的端口相同，对于Agent Proxy就是Server**

### Zabbix Web 添加 

![](https://i.imgur.com/U7JFqTM.png)

![](https://i.imgur.com/F6IYnZ5.png)

点击`Add`即可 

![](https://i.imgur.com/juLfJAU.png)

![](https://i.imgur.com/QfVAEEQ.png)

我们需要将这台主机的`Server`设置为Proxy 
编辑`192.168.56.12` 这台主机，需要将Server的`IP`地址修改成自己的 
因为现在是主动模式，我们只需要修改主动模式的Server即可

    [root@linux-node2 ~]# vim /etc/zabbix/zabbix_agentd.conf 
    ServerActive=192.168.56.12
    #配置文件修改完需要重启
    [root@linux-node2 ~]# systemctl restart zabbix-agent

这时候我们就可以看到那个`proxy`都管理了那些机器,做到方便管理的机制 

![](https://i.imgur.com/TCSCEwm.png)

proxy简单的理解就是一个Server

完！ 

转自：[Zabbix 3.0 分布式监控 [九]](https://www.abcdocker.com/abcdocker/1506)