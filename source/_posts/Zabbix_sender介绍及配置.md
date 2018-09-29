---
title: Zabbix_sender介绍及配置
date: 2016-11-28 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

## Zabbix_sender是什么?有什么作用？
　　zabbix获取`key值`有超时时间，如果自定义的`key`脚本一般需要执行很长时间，这根本没法去做监控，那怎么办呢？这时候就需要使用zabbix监控类型`zabbix trapper`，配合`zabbix_sender`给它传递数据。所以说`zabbix_sender`是更新`items值`最快的方式

### 安装
#### 在centos5上安装

    rpm -ivh http://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/5/x86_64/zabbix-sender-3.0.5-1.el5.x86_64.rpm

#### 在centos6上安装zabbix_sender

    rpm -ivh http://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/6/x86_64/zabbix-sender-3.0.5-1.el6.x86_64.rpm

#### 在centos7上安装zabbix_sender

    rpm -ivh http://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/7/x86_64/zabbix-sender-3.0.5-1.el7.x86_64.rpm

### 命令解释
`zabbix_sender`命令详解

> 最简易使用方法一:

> zabbix_sender -z server -s host -k key -o value

> 最简易使用方法二：

> zabbix_sender -c config-file -k key -o value

> 最简易使用方法三：

> zabbix_sender -z server -i file


更多的使用方法可以`man zabbix_sender`

**主要的使用参数**

      -c --config <file>   zabbix_agent配置文件绝对路径
      -z --zabbix-server <server>   zabbix server的IP地址
      -p --port <server port>  zabbix server端口.默认10051
      -s --host <hostname>   主机名，与zabbix_server web上主机的hostname一致

例如 

![](https://i.imgur.com/4W44aEd.png)

      -I --source-address <IP address>   源IP
      -k --key <key>  监控项的key
      -o --value <key value>key值
      -i --input-file <input file>  从文件里面读取hostname、key、value 一行为一条数据，使用空格作为分隔符，如果主机名带空格，那么请使用双引号包起来
      -r --real-time将数据实时提交给服务器
      -v --verbose 详细模式, -vv 更详细

### 案例
下面：我们创建一个监控项`item` 

![](https://i.imgur.com/WwPnASs.png)

    zabbix_sender -z 192.168.56.11 -s 192.168.56.100 -k login.users -o 111 

如下图所示 

![](https://i.imgur.com/CAiz4ro.png)

检验 

![](https://i.imgur.com/FVqAqso.png)

`-o`的值也可以引用命令：

    [root@muban ~]# zabbix_sender -z 192.168.56.11 -s 192.168.56.100 -k login.users -o $(w|sed '1,2d'|wc -l)

使用`zabbix_sender`批量发送 
首先多准备几个`zabbix_trapper`类型的监控项 

![](https://i.imgur.com/3DeMoy9.png)

编写批量列表，每行以`hostname`、`key`、`value`的方式

    [root@muban ~]# cat f.txt 
    192.168.56.100 login.users 12
    192.168.56.100 login.users1 13
    192.168.56.100 login.users2 14
    192.168.56.100 login.users3 15

测试

    zabbix_sender -z 192.168.56.11 -i f.txt

![](https://i.imgur.com/MA8ScnJ.png)

![](https://i.imgur.com/fGUBsC3.png)

转自：[Zabbix_sender介绍及配置 ](https://www.abcdocker.com/abcdocker/1707)