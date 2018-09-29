---
title: Zabbix 3.0 主备模式 [八]
date: 2016-11-20 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

## 监控常遇到的问题？ 
　　**1.监控主机多，性能跟不上，延迟大**
 
　　**2.多机房，防火墙因素**
 
Zabbix轻松解决以上问题，Nagios不太好解决的问题。

**Zabbix 模式介绍：**
 
**1、被动模式**
 
**2、主动模式**

　**　默认是被动模式，我们可以通过以下方式查看监控项是什么模式**
 
![](https://i.imgur.com/EIm1pC0.png)

因为我们使用的是模板，无法进行修改。我们可以修改配置文件或者新建item的时候设置。 

![](https://i.imgur.com/VqNsfCP.png)

**注意：**
 
**1、当监控主机超过300+，建议使用主动模式（此处是一个经验值，要根据服务器的硬件来进行考虑）**

**2、还需要保证Queue对列里面没有延迟的主机**

## Queue 对列介绍 
如果此处的延迟主机有点多的话，我们就需要将被动模式修改为主动模式. 

![](https://i.imgur.com/LEc3hPt.png)

主动模式设置
将192.168.56.12监控设置为主动模式 
1、修改配置文件 
为了方便模拟，我们将node2(192.168.56.12)从Zabbix删除从新添加 

![](https://i.imgur.com/PsP6Ayc.png)

    [root@linux-node2 ~]# vim /etc/zabbix/zabbix_agentd.conf
    #Server=192.168.56.11
    #我们需要注释Server，因为这个是被动模式用的
    StartAgents=0
    #设置为0之后就不会TCP端口，之前监听TCP端口是因为Server要去问agent信息所以需要开启
    ServerActive=192.168.56.11
    #此处可以是IP或者是域名，他会连接10051端口
    Hostname=linux-node2.example.com
    #唯一识别符，我们需要修改成我们本机的主机名。如果我们不设置，它默认会通过item来获取
    [root@linux-node2 ~]# systemctl restart zabbix-agent.service 
    保存重启

保存重启之后我们可以查看我们监听的一些端口，因为我们关闭的被动模式所以不会在监听zabbix端口了

    [root@linux-node2 ~]# netstat -lntup
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address   Foreign Address State   PID/Program name
    tcp0  0 0.0.0.0:22  0.0.0.0:*   LISTEN  1073/sshd   
    tcp0  0 127.0.0.1:250.0.0.0:*   LISTEN  2498/master 
    tcp6   0  0 :::44589:::*LISTEN  9052/java   
    tcp6   0  0 :::8080 :::*LISTEN  9052/java   
    tcp6   0  0 :::22   :::*LISTEN  1073/sshd   
    tcp6   0  0 :::8888 :::*LISTEN  9052/java   
    tcp6   0  0 ::1:25  :::*LISTEN  2498/master 
    tcp6   0  0 :::39743:::*LISTEN  9052/java   
    tcp6   0  0 127.0.0.1:8005  :::*LISTEN  9052/java   
    tcp6   0  0 :::8009 :::*LISTEN  9052/java  

我们可以查看日志，进行检查

    [root@linux-node2 ~]# tailf /var/log/zabbix/zabbix_agentd.log
     14932:20161011:084303.210 **** Enabled features ****
     14932:20161011:084303.210 IPv6 support:  YES
     14932:20161011:084303.210 TLS support:   YES
     14932:20161011:084303.210 **************************
     14932:20161011:084303.210 using configuration file: /etc/zabbix/zabbix_agentd.conf
     14932:20161011:084303.210 agent #0 started [main process]
     14933:20161011:084303.227 agent #1 started [collector]
     14934:20161011:084303.227 agent #2 started [active checks #1]
     14934:20161011:084303.271 no active checks on server [192.168.56.11:10051]: host [linux-node2.example.com] not found
     14934:20161011:084503.415 no active checks on server [192.168.56.11:10051]: host [linux-node2.example.com] not found

**日志解释：** 

`zabbix—agent`设置完主动模式后，会去主动问`server`需求。相当于入职刚入职运维需要老大进行分配任务。并且以后就会根据这个任务清单进行执行 因为我们还没有配置`server`，所以现在会出现错误

**Zabbix-web设置 **

我们需要添加zabbix-agent 

![](https://i.imgur.com/gKCRdQV.png)

![](https://i.imgur.com/ZXm01Vt.png)

**添加模板**，`zabbix`没有提供主动模式的模板。所以我们需要克隆一下OS Linux 

![](https://i.imgur.com/jYN2kbI.png)

找到OS Linux 模板，移动到最下面 点击复制 

![](https://i.imgur.com/TbrFCQR.png)

我们从新进行设置名称 

![](https://i.imgur.com/Ojjd6AP.png)

修改我们刚刚添加的模板名为`OS Linux Active` 

![](https://i.imgur.com/hLLbBjF.png)

我们点击刚刚创建模板的item 

![](https://i.imgur.com/aFNr6AR.png)

![](https://i.imgur.com/sAWRdBq.png)

![](https://i.imgur.com/6GEiweF.png)

然后选择最下方`Update` 
结果如下： 

![](https://i.imgur.com/DJdFkkE.png)

**在次查看模板，发现zabbix还依赖一个模板。我们需要把它也改了或者是删掉。**

**我们添加主机 **

![](https://i.imgur.com/tKY7DBr.png)

添加模板 

![](https://i.imgur.com/VT2o1HH.png)

![](https://i.imgur.com/uIICvT3.png)

![](https://i.imgur.com/y0a4gdx.png)

#提示：我们已经可以获取到数据了，但是发现zabbix 这个模块发红。可能是由于我们没有修改他的依赖造成的 
如下图： 

![](https://i.imgur.com/SoR1gms.png)

可能是通过agent.ping来获取信息,没有看过源码 所以不太清楚，我研究它 

![](https://i.imgur.com/rPOpPxS.png)

zabbix主备模式完成 

转自：[Zabbix 3.0 主备模式 [八]](https://www.abcdocker.com/abcdocker/1504)