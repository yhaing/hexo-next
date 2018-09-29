---
title: Zabbix 3.0 部署监控 [三]
date: 2016-10-11 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

# Dashboard首页信息介绍

![](https://i.imgur.com/7SCQVse.png)


<font size="5">**Status of Zabbix（Zabbix状态）介绍**</font><br /> 

![](https://i.imgur.com/pbHJOBK.png)

    Zabbix server is running   #Zabbix服务器是否运行
    Number of hosts (enabled/disabled/templates)  #主机数量（已启用/已禁用/模板）
    Number of items (enabled/disabled/not supported)   #监控项数量（已启用/已禁用/不支持）
    Number of triggers (enabled/disabled [problem/ok])   #触发器数量（已启用/已禁用/问题/正常）
    Number of users (online) #用户数（线上）
    Required server performance, new values per second #要求的主机性能，每秒新值

<font size="4">**此处需要注意的事项如下：**</font><br />  
1、需要时刻关注那些主机数量中已禁用的（例如：那一天有一台监控有问题，顺手关闭了。没有打开 结果后期导致监控出现问题）
 
2、监控项数量里面最好不要放置已禁用，要么删除这个监控项或者不让他报警。尽量不要给他禁用 

3、触发器只禁用几个没什么大问题，但是如果一下禁用几十个不方便进行管理 

4、正式环境最好划分主机组，可以按照业务划分，类型划分。那个出现问题都方便查看处理

# Latest data 最新数据介绍

![](https://i.imgur.com/o2EQxaE.png)

## 加入监控
　　刚刚之前我们一直使用的是一台服务器，因为不方便解释。我们新添加一台服务器 
　加入监控的几个步骤：
 
　　1、安装软件 

　　2、修改配置 

### 1、设置yum源
    
    [root@linux-node2 ~]# rpm -ivh http://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm

### 2、安装软件包
    
    [root@linux-node2 ~]# yum install -y zabbix-agent

### 3、修改配置文件

    [root@linux-node2 ~]# vim /etc/zabbix/zabbix_agentd.conf 
    Server=192.168.56.11
    ServerActive=192.168.56.11
    #提示：这里的IP地址改成Server端的IP地址

### 4、启动

[root@linux-node2 ~]# systemctl start zabbix-agent
[root@linux-node2 ~]# netstat -lntup|grep zabbix
tcp0  0 0.0.0.0:10050   0.0.0.0:*   LISTEN  10088/zabbix_agentd 
tcp6   0  0 :::10050:::*LISTEN  10088/zabbix_agentd 

### 5、web界面设置 
克隆~ 

![](https://i.imgur.com/9oDdthl.png)

**步骤**：我们随便点击一个进去。拉到最下面有一个全部克隆 

![](https://i.imgur.com/je7rPBd.png)

剩下的我们就改一下就可以了 

![](https://i.imgur.com/rCyyqpU.png)

模板修改 

![](https://i.imgur.com/HDnUIkN.png)

其他的就没有什么可以配置的，模板主要是添加`Template OS Linux`。然后我们选择`Add`即可
 
**创建完成如下：** 

![](https://i.imgur.com/SKTdd0d.png)

新添加的`IP`如上述所示

## Maps 优化设置

上次只是简单的连接线的设置，这次我们进行深入设置
 
**路径：**`Monitoring--->Maps--->Edit map`进行修改 

![](https://i.imgur.com/pSatyDS.png)

我们点击`Zabbix server`没有设置主机的，选择`Host` 修改`linux-node2`。 

![](https://i.imgur.com/Ma17tG1.png)

**提示：**此处我们修改了`2`台主机，这个可以根据业务需求进行设置 

![](https://i.imgur.com/vfAbfDU.png)

我们新添加一台，然后进行连接。`Ctrl + 主机 `然后点击`Link：Add` 
　　例如我们想查看他们的`流量带宽` 

![](https://i.imgur.com/uU59h42.png)

首先，他们必须要连接在一起，然后点击`Links`选项后面的`Edit`进行编辑
 
我们可以在`Label`表里面写监控项的值
 
我们可以在`Configuration--->Hosts--->items`中查看到
 
![](https://i.imgur.com/cwTmQZs.png)

括号内写入发下：

    {linux-node2.example.com:net.if.out[eth0].last(0)}
    linux-node2.example.com=主机名
    net.if.out=key值
    last（0）=获取最新的一个数据

![](https://i.imgur.com/JI5Vhre.png)

　　现在我们就可以实时的监控流量 
　　切记需要`update`

**保存如下图显示**

![](https://i.imgur.com/mmLWCkA.png)

## 如何让Zabbix报警
　　我们可以先打开`Events`查看事件 

![](https://i.imgur.com/6Un67WT.png)

<font size="4">**zabbix事件有很多类型**</font><br /> 

<font size="4">**`Trigger`=触发器的事件**</font><br />
 
<font size="4">**`Disovery`=自动发现事件**</font><br /> 
<font size="4">**还有内部的事件以及自动注册的事件**</font><br /> 

![](https://i.imgur.com/CdpCAxY.png)

我们可以选择`主机`，查看相对应的事件

`Zabbix`的报警可以当做事件通知，当这个事件发生时。`zabbix`进行通知（报警）
 
　　<font size="4">**事件报警分为`2`种方式：**</font><br />  
<font size="4">**1、怎么通知**</font><br /> 
<font size="4">**2、通知给谁**</font><br /> 

<font size="4">**Zabbix通知方式：**</font><br />  
Zabbix通知方式通过`Actions`进行通知
 
![](https://i.imgur.com/vYyyNvW.png)

`Zabbix`默认有一个，我们可以点开进行查看 

![](https://i.imgur.com/lwE2leS.png)

<font size="4">**条件设置**</font><br />  

![](https://i.imgur.com/vGMdKBd.png)

<font size="4">**操作设置**</font><br />  

![](https://i.imgur.com/UAveG2h.png)

![](https://i.imgur.com/rqswlPh.png)


<font size="4">**温馨提示：**</font><br />保存的时候需要先点击下方小的Update 否则就木有啦,这里的步骤可以让报警邮件发送的级别、例如：先发送给`运维、项目经理、项目总监`等
 
**例如如下：** 

![](https://i.imgur.com/pv09ZOh.png)

　　刚刚的填写完成，现在提示的是`1-2 `发送的人 我们可以点击下面的`New`在添加几个 

![](https://i.imgur.com/Q1tkOeF.png)

　　模拟设置，当报警`1-2`次时候发送给XX，`2-4`次发送给`XX`。 依次叠加 
　　 我们需要配置报警媒介类型，用于发送邮件 

![](https://i.imgur.com/ldCMM7d.png)

**温馨提示：**`3.0`之前发送邮件需要启动邮件相关服务来进行安全认证，`3.0`之后默认自带安全认证 
　　**我们以qq邮箱为例** 

![](https://i.imgur.com/fti9uIo.png)

　　我们还需要配置`用户`的邮箱，因为上面已经选择发送给那个`用户`。接下来就改配置用户的邮箱 

![](https://i.imgur.com/o3Y31bv.png)

我们点开之后选择`Media`（报警媒介进行设置）如果看不懂英文我们可以设置中文 

![](https://i.imgur.com/b7Vi2My.png)

然后我们选择下方的`Add` 

![](https://i.imgur.com/FFhzG8I.png)

设置收件人地址 

![](https://i.imgur.com/SsyuLeh.png)

小结：步骤就不截图了，可以调成中文，按照步骤来。

> 1、报警媒介

> 2、动作（active）配置（操作--编辑）  注意点小的update

> 3、创建用户群组（注意权限）

> 4、创建用户（权限和报警媒介设置）权限只能按照用户组分配（我们可以选择用户/管理员/超级管理员）

**提示：**添加新主机后，要注意确认权限分配 

<font size="5">**我们的使用QQ邮箱需要开启SNMP和一个授权码。 填写发件人密码时需要设置授权码为密码**</font><br /> 

![](https://i.imgur.com/iU4apaa.png)

邮件结果如下： 
异常 

![](https://i.imgur.com/tmTrw5V.png)

因为我们开启了正常之后继续发送邮件，所以正常之后邮件如下 

![](https://i.imgur.com/Xth6JhZ.png)

**提示**：当异常时它会一直发邮件，直到服务正常或者匹配规则到时

转载自：[Zabbix 3.0 部署监控 [三] ](https://www.abcdocker.com/abcdocker/1460)