---
title: Zabbix 3.0 自动化监控 [十]
date: 2016-11-25 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

## 自动化分类

所有的自动化都可以分为`2`种
 
**1.自动注册**
 
　**Zabbix agnet 自动添加**
 
**2.主动发现**
 
　**1.自动发现 Discover**
 
　**2.zabbix api**
 
　因为我们只有`2`台`web`，为了方便演示。我们将原来添加的`proxy`删掉. 

![](https://i.imgur.com/ELGcQht.png)

**提示：** 主动模式下设置自动注册

### 一、自动注册设置

**agent配置文件修改**

    [root@linux-node2 ~]# vim /etc/zabbix/zabbix_agentd.conf 
    LogFileSize=0
    StartAgents=0
    Server=192.168.56.11
    ServerActive=192.168.56.11
    Hostname=192.168.56.11
    HostMetadata=system.uname
    #Server IP地址
    HostMetadataItem=system.uname
    #特征
    1.可以我们自己写一个特征
    2.我们执行一个key
    #手写级别大于执行key

过滤出我们的配置[如下]

    [root@CentOS6 zabbix]# egrep -v "#|^$" zabbix_agentd.conf
    PidFile=/var/run/zabbix/zabbix_agentd.pid
    LogFile=/var/log/zabbix/zabbix_agentd.log
    LogFileSize=0
    StartAgents=0
    Server=192.168.56.11
    ServerActive=192.168.56.11
    Hostname=192.168.56.12
    HostMetadata=system.uname
    Include=/etc/zabbix/zabbix_agentd.d/

我们先不重启，因为重启就生效了。我们需要设置一个规则.

> 注意自动发现必须要设置ServerActive让客户端启动主动去寻找服务端 
> 提示，zabbix-agent起来的时候去找server，这时候就会产生一个事件，然后我们可以基于这个事件来完成一个动作

**提示：** zabbix-agent起来的时候回去找Server，这时候就会产生一个事件，然后我们可以基于这个事件来完成一个动作。 

![](https://i.imgur.com/645wzuZ.png)

我们需要选中，然后在进行创建 

![](https://i.imgur.com/ru54Yix.png)

![](https://i.imgur.com/lv40PEK.png)

![](https://i.imgur.com/nvTh8I5.png)

**如果选项匹配到Linux，为什么匹配Linux呢？ 因为Linux 可以在输入任何命令都可以生成**

    [root@linux-node2 ~]# uname
    Linux
    [root@linux-node2 ~]# uname -a
    Linux linux-node2.example.com 3.10.0-327.36.1.el7.x86_64 #1 SMP Sun Sep 18 13:04:29 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux

**提示：** 需要点击小的Add 才可以继续操作 

![](https://i.imgur.com/C59pMXg.png)

设置操作 

![](https://i.imgur.com/FIiDZrH.png)

我们先点击`Add`，在选择`Host` 

![](https://i.imgur.com/SIY5rLg.png)

我们在添加一个主机组，随便选一个就可以。 

![](https://i.imgur.com/mhFWBHU.png)

我们在添加一个模板

**解释：** 这样设置后我发现你这台主机我会给你设置一个主机组和一个模板。并且是Linux
 
**最后我们选择Add**

![](https://i.imgur.com/IedIJTG.png)

修改完之后我们在`重启`一下

    [root@linux-node2 ~]# systemctl restart zabbix-agent.service 

![](https://i.imgur.com/yGZ1vhe.png)

如果还没有出来，我们可以稍等一会 

![](https://i.imgur.com/GtAB89G.png)


自动注册完!

------------------------分割线----------------------

## 二、自动发现设置
因为我们的服务器只用了`2`台，所以昨晚`自动注册`我们在把它停掉。要不总会影响我们 

![](https://i.imgur.com/t64T9OC.png)

我们在删除刚刚添加的主机 

![](https://i.imgur.com/8wZc5vg.png)

自动发现可以去扫描IP地址范围（需要手动设置）进行发现的动作 

![](https://i.imgur.com/DBXofPG.png)

**官方说明：** [https://www.zabbix.com/documentation/3.0/manual/discovery/network_discovery](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/discovery/network_discovery)

### 创建Zabbix自动发现（生产一般不用）
 
![](https://i.imgur.com/ON8I4IA.png)

![](https://i.imgur.com/wwQ4dYQ.png)

**唯一的标识我们可以设置IP地址，或者key值** 

![](https://i.imgur.com/BEam15U.png)

　　然后我们创建一个`Action`(动作) 

![](https://i.imgur.com/7hXMUP6.png)

![](https://i.imgur.com/0CSJ7nV.png)

现在它自己就添加上去了 

![](https://i.imgur.com/R7jAGxs.png)

## 三、API介绍
　 `Zabbix`提供了一个丰富的`API`，`Zabbix`提供的`API`有`2`种功能。
 
**一个是管理**

**一个是查询**

![](https://i.imgur.com/uTn1Jgl.png)

请求方法 `POST` 
我们可以进行访问查看 

![](https://i.imgur.com/1TV6Wld.png)

无法打开，我们需要进行POST请求才可以。 
官方说明文档：[https://www.zabbix.com/documentation/3.0/manual/api](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/api)

    curl -s -X POST -H 'Content-Type:application/json-rpc' -d'
    {
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
    "user": "zhangsan",
    "password": "123456"
    },
    "id": 1
    }' http://192.168.56.11/zabbix/api_jsonrpc.php |  python -m json.tool
    
`-d` 请求的内容 

`-H` 类型 

`id` 名字，类似一个标识 

`user` 我们登陆用的是zhangsan 默认是Admin 

`password` 默认是zabbix，我们修改为123456了

    [root@linux-node1 ~]# curl -s -X POST -H 'Content-Type:application/json-rpc' -d'
    > {
    > "jsonrpc": "2.0",
    > "method": "user.login",
    > "params": {
    > "user": "zhangsan",
    > "password": "123456"
    > },
    > "id": 1
    > }' http://192.168.56.11/zabbix/api_jsonrpc.php |  python -m json.tool
    --------------------------分割线------------------------
    下面是返回的结果！！！！！！！！！！！！！！！！！！！！！！
    {
    "id": 1,
    "jsonrpc": "2.0",
    "result": "d8286f586348b96b6b0f880db3db8a02"
    }

**例如：我们获取所有主机的列表 **
官方文档：[https://www.zabbix.com/documentation/3.0/manual/api/reference/host/get](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/api/reference/host/get)

    curl -s -X POST -H 'Content-Type:application/json-rpc' -d'
    {
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
    "output": ["host"]
    },
    "auth": "d8286f586348b96b6b0f880db3db8a02",
    "id": 1
    }' http://192.168.56.11/zabbix/api_jsonrpc.php |  python -m json.tool

**提示：** auth里面填写的是我们刚刚返回的`result`里面的值,如果我们在[`"hostid"`]加上`id`就会显示`id`。想全显示主机名就直接写`host`

    [root@linux-node1 ~]# curl -s -X POST -H 'Content-Type:application/json-rpc' -d'
    {
    "jsonrpc": "2.0",
    "method": "host.get",
    "params": {
    "output": ["host"]
    },
    "auth": "d8286f586348b96b6b0f880db3db8a02",
    "id": 1
    }' http://192.168.56.11/zabbix/api_jsonrpc.php |  python -m json.tool
    {
    "id": 1,
    "jsonrpc": "2.0",
    "result": [
    {
    "host": "Zabbix server",
    "hostid": "10084"
    },
    {
    "host": "linux-node1.example.com",
    "hostid": "10105"
    },
    {
    "host": "linux-node1.example.com1",
    "hostid": "10107"
    },
    {
    "host": "linux-node2.example.com",
    "hostid": "10117"
    }
    ]
    }
　　　　　　 　　　　　　　　　　　　　　　　　　对比图 

![](https://i.imgur.com/WJNrRcX.png)

例如：如何获取模板 
官方文档：[https://www.zabbix.com/documentation/3.0/manual/api/reference/template/get](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/api/reference/template/get)

    curl -s -X POST -H 'Content-Type:application/json-rpc' -d'
    {
    "jsonrpc": "2.0",
    "method": "template.get",
    "params": {
    "output": "extend"
    },
    "auth": "d8286f586348b96b6b0f880db3db8a02",
    "id": 1
    }' http://192.168.56.11/zabbix/api_jsonrpc.php |  python -m json.tool

默认太多不发了，看图！ 

![](https://i.imgur.com/GDPoVQn.png)

　　**过滤 **
过滤主机有`OS LINUX`的模板

    curl -s -X POST -H 'Content-Type:application/json-rpc' -d'
    {
    "jsonrpc": "2.0",
    "method": "template.get",
    "params": {
    "output": "extend",
     "filter": {
    "host": [
    "Template OS Linux"
    ]
    }
    },
    "auth": "d8286f586348b96b6b0f880db3db8a02",
    "id": 1
    }' http://192.168.56.11/zabbix/api_jsonrpc.php |  python -m json.tool

效果图如下！ 

![](https://i.imgur.com/PiFga9i.png)

　　我们提供一个快速认证的`Python`脚本 
链接：[http://pan.baidu.com/s/1gf0pQwF](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://pan.baidu.com/s/1gf0pQwF) 密码：m7dq 

脚本内容如下

    [root@linux-node1 ~]# cat zabbix_auth.py 
    #!/usr/bin/env python
    # -*- coding:utf-8 -*-
    import requests
    import json
    url = 'http://192.168.56.11/zabbix/api_jsonrpc.php'
    post_data = {
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
    "user": "zhangsan",
    "password": "123123"
    },
    "id": 1
    }
    post_header = {'Content-Type': 'application/json'}
    ret = requests.post(url, data=json.dumps(post_data), headers=post_header)
    zabbix_ret = json.loads(ret.text)
    if not zabbix_ret.has_key('result'):
    print 'login error'
    else:
    print zabbix_ret.get('result')

我们可以执行一下进行查看 
提示： 需要修改里面的`用户名`和`密码`！

    #安装python环境
    [root@linux-node1 ~]# yum install python-pip -y
    [root@linux-node1 ~]# pip install requests
    You are using pip version 7.1.0, however version 8.1.2 is available.
    You should consider upgrading via the 'pip install --upgrade pip' command.
    Collecting requests
      Downloading requests-2.11.1-py2.py3-none-any.whl (514kB)
    100% |████████████████████████████████| 516kB 204kB/s 
    Installing collected packages: requests
    Successfully installed requests-2.11.1
    ################################################
    ################################################
    ################################################
    执行结果
    [root@linux-node1 ~]# python zabbix_auth.py 
    5b21317186f2a47404214556c5c1d846

## 四、案例：使用API进行自动添加主机
首先我们需要删除主机和自动发现 

![](https://i.imgur.com/zayEEz7.png)

![](https://i.imgur.com/ezo9AZM.png)

我们使用API来实现自动添加监控主机 
使用API添加主机：[https://www.zabbix.com/documentation/3.0/manual/api/reference/host/create](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://www.zabbix.com/documentation/3.0/manual/api/reference/host/create)

    curl -s -X POST -H 'Content-Type:application/json-rpc' -d'
    {
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
    "host": "Zabbix agent 192",
    "interfaces": [
    {
    "type": 1,
    "main": 1,
    "useip": 1,
    "ip": "192.168.56.12",
    "dns": "",
    "port": "10050"
    }
    ],
    "groups": [
    {
    "groupid": "8"
    }
    ],
    "templates": [
    {
    "templateid": "10001"
    }
    ]
    },
    "auth": "5b21317186f2a47404214556c5c1d846",
    "id": 1
    }' http://192.168.56.11/zabbix/api_jsonrpc.php |  python -m json.tool

**用户组ID获取方法 **

![](https://i.imgur.com/Pt2dnPB.png)

模板IP查看方法 

![](https://i.imgur.com/hujCSqX.png)

执行结果如下：

    [root@linux-node1 ~]# curl -s -X POST -H 'Content-Type:application/json-rpc' -d'
    > {
    > "jsonrpc": "2.0",
    > "method": "host.create",
    > "params": {
    > "host": "Zabbix agent 192",
    > "interfaces": [
    > {
    > "type": 1,
    > "main": 1,
    > "useip": 1,
    > "ip": "192.168.56.12",
    > "dns": "",
    > "port": "10050"
    > }
    > ],
    > "groups": [
    > {
    > "groupid": "8"
    > }
    > ],
    > "templates": [
    > {
    > "templateid": "10001"
    > }
    > ]
    > },
    > "auth": "5b21317186f2a47404214556c5c1d846",
    > "id": 1
    > }' http://192.168.56.11/zabbix/api_jsonrpc.php |  python -m json.tool
    {
    "id": 1,
    "jsonrpc": "2.0",
    "result": {
    "hostids": [
    "10118"
    ]
    }
    }

查看Zabbix 页面 

![](https://i.imgur.com/W1MmtJZ.png)

**提示：** 里面的主机名/模板 都是我们设置好的

Zabbix完！ 

转自：[Zabbix 3.0 自动化监控 [十]](https://www.abcdocker.com/abcdocker/1510)