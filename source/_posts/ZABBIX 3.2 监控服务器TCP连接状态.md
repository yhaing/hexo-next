---
title: ZABBIX 3.2 监控服务器TCP连接状态
date: 2017-7-29 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/HNonS5h.jpg)

<!--more-->

# ZABBIX 3.2 监控服务器TCP连接状态


TCP 11种状态图 (我也记不住所有的) 

![](https://i.imgur.com/sa3RnNk.jpg)

TCP连接可以使用命令获取

    [root@abcdocker ~]# netstat -an|awk '/^tcp/{++S[$NF]}END{for(a in S) print a,S[a]}' 
    TIME_WAIT 99
    CLOSE_WAIT 44
    FIN_WAIT1 1
    FIN_WAIT2 5
    ESTABLISHED 275
    LAST_ACK 1
    LISTEN 25

可以使用`man netstat`查看`TCP`的各种状态信息描述

    LISTEN - 侦听来自远方TCP端口的连接请求； 
    
    SYN-SENT -在发送连接请求后等待匹配的连接请求； 
    
    SYN-RECEIVED - 在收到和发送一个连接请求后等待对连接请求的确认； 
    
    ESTABLISHED- 代表一个打开的连接，数据可以传送给用户； 
    
    FIN-WAIT-1 - 等待远程TCP的连接中断请求，或先前的连接中断请求的确认；
    
    FIN-WAIT-2 - 从远程TCP等待连接中断请求； 
    
    CLOSE-WAIT - 等待从本地用户发来的连接中断请求； 
    
    CLOSING -等待远程TCP对连接中断的确认； 
    
    LAST-ACK - 等待原来发向远程TCP的连接中断请求的确认； 
    
    TIME-WAIT -等待足够的时间以确保远程TCP接收到连接中断请求的确认； 
    
    CLOSED - 没有任何连接状态；

## 一、编写配置文件

    [root@abcdocker zabbix]# grep "Include" zabbix_agentd.conf
    Include=/etc/zabbix/zabbix_agentd.d/*.conf
    我们查看我们设置的Include目录，这下面的*.conf文件都是可以读取的

编写配置文件

    [root@abcdocker zabbix_agentd.d]# cat status.conf 
    UserParameter=tcp.status[*],/etc/zabbix/zabbix_agentd.d/tcp_status.sh "$1"
    咳咳，注意听讲(敲黑板)
    UserParameter= 后面是key的名称
    /etc/zabbix/zabbix_agentd.d 存放脚本的路径
    以前的文章有写过，大家可以看我的zabbix板块

复制脚本

    [root@abcdocker zabbix_agentd.d]# cat tcp_status.sh 
    #!/bin/bash
    #this script is used to get tcp and udp connetion status
    #tcp status
    metric=$1
    tmp_file=/tmp/tcp_status.txt
    /bin/netstat -an|awk '/^tcp/{++S[$NF]}END{for(a in S) print a,S[a]}' > $tmp_file
    case $metric in
       closed)
      output=$(awk '/CLOSED/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
    ;;
       listen)
      output=$(awk '/LISTEN/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
    ;;
       synrecv)
      output=$(awk '/SYN_RECV/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
    ;;
       synsent)
      output=$(awk '/SYN_SENT/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
    ;;
       established)
      output=$(awk '/ESTABLISHED/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
    ;;
       timewait)
      output=$(awk '/TIME_WAIT/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
    ;;
       closing)
      output=$(awk '/CLOSING/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
    ;;
       closewait)
      output=$(awk '/CLOSE_WAIT/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
    ;;
       lastack)
      output=$(awk '/LAST_ACK/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
     ;;
       finwait1)
      output=$(awk '/FIN_WAIT1/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
     ;;
       finwait2)
      output=$(awk '/FIN_WAIT2/{print $2}' $tmp_file)
      if [ "$output" == "" ];then
     echo 0
      else
     echo $output
      fi
     ;;
     *)
      echo -e "\e[033mUsage: sh  $0 [closed|closing|closewait|synrecv|synsent|finwait1|finwait2|listen|established|lastack|timewait]\e[0m"
    esac

**提示： 脚本来源于网络**

因为脚本是把tcp的一些信息存放在/tmp/下，为了zabbix可以读取到我们设置zabbix可以读的权限

    [root@abcdocker zabbix_agentd.d]# chmod +x tcp_connection_status.sh 
    [root@abcdocker zabbix_agentd.d]# chown zabbix.zabbix /tmp/tcp_status.txt

重点： 这里要添加执行权限和tcp_status的**属主**和**属组**

执行脚本测试

既然脚本写完了，我们就需要执行一下

    [root@abcdocker zabbix_agentd.d]# zabbix_get -s 127.0.0.1  -k tcp.status[established]
    8
    [root@abcdocker zabbix_agentd.d]# zabbix_get -s 127.0.0.1  -k tcp.status[lastack]
    0
    [root@abcdocker zabbix_agentd.d]# zabbix_get -s 127.0.0.1  -k tcp.status[finwait1]
    0
    [root@abcdocker zabbix_agentd.d]# zabbix_get -s 127.0.0.1  -k tcp.status[timewait]
    101
    
如果没有zabbix_get需要yum安装

## 二、WEB界面配置
### 1. 创建模板 

![](https://i.imgur.com/QZOfPbF.png)

### 2.设置模板 

![](https://i.imgur.com/C4z5XoC.png)

### 3.添加监控项 

![](https://i.imgur.com/G06pxB6.png)

添加完基本上就是下面这样 

![](https://i.imgur.com/AQbppJ8.png)

为了方便大家添加，我已经将name和key整理如下. 手动添加即可

    Name Key
    CLOSED  tcp.status[closed]
    CLOSE_WAIT  tcp.status[closewait]
    CLOSING tcp.status[closing]
    ESTABLISHED tcp.status[established]
    FIN WAIT1   tcp.status[finwait1]
    FIN WAIT2   tcp.status[finwait2]
    LAST ACKtcp.status[lastack]
    LISTEN  tcp.status[listen]
    SYN RECVtcp.status[synrecv]
    SYN SENTtcp.status[synsent]
    TIME WAIT   tcp.status[timewait]

我这里提供模板： 
链接：[http://pan.baidu.com/s/1sle6oNj](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://pan.baidu.com/s/1sle6oNj) 密码：oqgs 
可以直接使用模板导入即可

### 4.添加图表 
　我们所有的操作都在TCP 模板下面添加和设置的，大家不要设置错了 

![](https://i.imgur.com/gO4gAOs.png)

![](https://i.imgur.com/UWlBFXz.png)

![](https://i.imgur.com/Yhd2zbI.png)

添加完之后我们点击`update`

## 三、添加主机

![](https://i.imgur.com/sdi8m8L.png)

![](https://i.imgur.com/Gmxqa3P.png)

进行查看 

![](https://i.imgur.com/rtJx7ID.png)

四、出图结果

![](https://i.imgur.com/mzIrfG4.png)

**小结：**

> 因为tcp连接数不太好设置触发器，因为业务不同，具体设置多少还是要根据需求来。因为我这是个人博客监控所以连接数是多少都可以！

关于tcp最大连接可以参考下面的文章 
[http://www.cnblogs.com/fjping0606/p/4729389.html](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.cnblogs.com/fjping0606/p/4729389.html) 

![](https://i.imgur.com/tdoHlDI.png)

关于ZABBIX更多相关文章请前往 ZABBIX板块

参考 [http://john88wang.blog.51cto.com/2165294/1586234/](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://john88wang.blog.51cto.com/2165294/1586234/)

转自：[ZABBIX 3.2 监控服务器TCP连接状态](https://www.abcdocker.com/abcdocker/2652)