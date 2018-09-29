---
title: Zabbix 3.0 监控MySQL [六]
date: 2016-11-15 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

## Mysql监控 
　　zabbix自带了一个监控mysql的模板，但是真正监控mysql的并不是zabbix自带的模板。而是percona公司的一个监控mysql模板 
　percona官网： www.percona.com

Percona组成介绍

> 1、php脚本    用来数据采集
> 2、shell脚本  用来调用采集信息
> 3、zabbix配置文件
> 4、zabbix模板文件

安装文档：[https://www.percona.com/doc/percona-monitoring-plugins/LATEST/zabbix/index.html](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.percona.com/doc/percona-monitoring-plugins/LATEST/zabbix/index.html) 
　　`percona` 利用的是`php`来获取`mysql`的相关信息，所以如果我们想使用`percona`插件监控`mysql`就需要在`agent`端安装`php`。在安装文档上有写哦~ 

![](https://i.imgur.com/LPN3zoa.png)

**安装步骤：** 查看上面的链接也可以进行安装 
我们安装在zabbix-server上，因为上面有一个MySQL

    [root@linux-node1 web]# yum install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
    [root@linux-node1 web]# yum install percona-zabbix-templates php php-mysql -y
    #percona插件是通过php去获取mysql的参数，所以我们要安装php和php-mysql
    我们可以查看它都安装了那些软件
    [root@linux-node1 web]# rpm -ql percona-zabbix-templates
    /var/lib/zabbix/percona
    /var/lib/zabbix/percona/scripts
    /var/lib/zabbix/percona/scripts/get_mysql_stats_wrapper.sh  #shell脚本
    /var/lib/zabbix/percona/scripts/ss_get_mysql_stats.php  #php获取mysql信息
    /var/lib/zabbix/percona/templates
    /var/lib/zabbix/percona/templates/userparameter_percona_mysql.conf #zabbix配置文件
    /var/lib/zabbix/percona/templates/zabbix_agent_template_percona_mysql_server_ht_2.0.9-sver1.1.6.xml  #zabbix模板文件
    在percona组成我们已经说过了，此处只是略微介绍。

我们将zabbix模板下载下来

    [root@linux-node1 web]# sz /var/lib/zabbix/percona/templates/zabbix_agent_template_percona_mysql_server_ht_2.0.9-sver1.1.6.xml

　　然后我们需要将模板通过web界面导入到zabbix中 
![](https://i.imgur.com/6igmagK.png)

![](https://i.imgur.com/pnG0we0.png)

**提示：**如果出现错误，可能是zabbix 3.0版本的问题。我们这里提供了一个生产的模板 
下载链接： [https://pan.baidu.com/s/1TgsPR3qjWyxjwKYQrz6fWQ](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://pan.baidu.com/s/1TgsPR3qjWyxjwKYQrz6fWQ)密码:u09h
 
然后从新上传即可

复制配置文件

    [root@linux-node1 web]# cp /var/lib/zabbix/percona/templates/userparameter_percona_mysql.conf /etc/zabbix/zabbix_agentd.d/
    [root@linux-node1 web]# ls /etc/zabbix/zabbix_agentd.d/
    #安装完软件包后会在/var/lib/zabbix/percona/templates/目录下产生一个配置文件，我们将它拷贝，因为在前面的博文中，我们已经修改过zabbix的配置文件[Include=/etc/abbix/zabbix_agentd.d/
    ] 所以将配置文件放在这个目录下，zabbix就会自己在这个目录下查找相关信息
    [root@linux-node1 web]# systemctl restart zabbix-agent.service 
    重启一下！

下面就应该配置与MySQL的连接 
在`/var/lib/zabbix/percona/scripts/ss_get_mysql_stats.php.cnf`创建一个文件

    [root@linux-node1 ~]# cat /var/lib/zabbix/percona/scripts/ss_get_mysql_stats.php.cnf
    <?php
    $mysql_user = 'root';
    $mysql_pass = '';
    #用户名密码可以自己创建，有密码写密码，没密码为空就好了

**提示：** 正常这里的用户我们应该创建一个专门用来监控的，由于我这里是测试环境。就不浪费时间了

## 测试
查看是否可以获取到值，随便找一个测试

    [root@linux-node1 ~]# cat /var/lib/zabbix/percona/templates/userparameter_percona_mysql.conf
    选择一个肯定有值的key
    [root@linux-node1 ~]# cat /var/lib/zabbix/percona/templates/userparameter_percona_mysql.conf|grep gm
    UserParameter=MySQL.read-views,/var/lib/zabbix/percona/scripts/get_mysql_stats_wrapper.sh gm
    测试结果如下：
    [root@linux-node1 ~]# cd /var/lib/zabbix/percona/scripts/
    [root@linux-node1 scripts]# ./get_mysql_stats_wrapper.sh gm
    1
    [root@linux-node1 scripts]# ./get_mysql_stats_wrapper.sh gw
    9736342
    可以获取到值，说明没有问题

**温馨提示：** shell脚本中数据库的路径是localhost，如果我们没有授权localhost会获取不到值

    [root@linux-node1 scripts]# cat get_mysql_stats_wrapper.sh 
    HOST=localhost
    RES=`HOME=~zabbix mysql -e 'SHOW SLAVE STATUS\G' | egrep '(Slave_IO_Running|Slave_SQL_Running):' | awk -F: '{print $2}' | tr '\n' ','`
    #mysql是通过命令来获取的，如果环境变量不一样 也可能造成影响

## Zabbix_Web界面配置 
　　模板已经上传到zabbix中，这时候我们就需要进行设置了 

![](https://i.imgur.com/YkTEoRR.png)

![](https://i.imgur.com/izXjfge.png)

提示： 我们还需要授权/tmp下的一个文件，因为默认情况下 zabbix在文件中获取的值 

![](https://i.imgur.com/7qE8wqx.png)

修改完就可以获取值了，所以我们还需要测试 

![](https://i.imgur.com/h11vUxM.png)

结果如下图 

![](https://i.imgur.com/9ShsBbD.png)

**思想：** 

　　如果出现错误我们需要先查看shell的脚本，因为shell是去调用php。 错误的因素有很多，最简单的方法就是用shell 后面加上key 看看是否可以有值。 
　　其中报错最多的地方就是php和mysql连接的问题，还有我们mysql授权的一些问题。

MYSQL监控 完！

转载自：[Zabbix 3.0 监控MySQL [六]](https://www.abcdocker.com/abcdocker/1498)