---
title: Zabbix Web 邮件报警
date: 2016-11-27 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->
zabbix 3.0版本系列会造成无法使用smtp进行报警我们可以使用邮件报警，可以参考文章[Zabbix 使用脚本发送邮件](https://www.abcdocker.com/abcdocker/2567)

完整配置邮件步骤如下：

**首先点击配置，选择报警媒介，点击邮件[Email]**

![](https://i.imgur.com/G0ogdw9.png)

![](https://i.imgur.com/p7hEx87.png)


**提示：这里的密码不是QQ登陆密码，而是QQ邮箱的授权密码** 

![](https://i.imgur.com/u5wBMVb.png)

**设置收件人邮箱** 

![](https://i.imgur.com/utQiAyY.png)

**设置发送邮件动作**

此处注意如果没有开启需要开启，要确保状态是Enabled 

![](https://i.imgur.com/DiLTtwR.png)

**这里可以设置脚本内容，我们默认就行** 

![](https://i.imgur.com/Juw66Ej.png)

**测试** 
我自己服务器安装zabbix 3.2(3.2安装文档)，zabbix 3.2有默认的网卡监控，我设置一个超过10M报警的动作。我们可以看邮件如下

**报警邮件**

![](https://i.imgur.com/rAcfe5m.png)

**恢复邮件** 

![](https://i.imgur.com/lkEdvL2.png)

谁要在说发送不了邮件，我打死他！

转自：[Zabbix Web 邮件报警](https://www.abcdocker.com/abcdocker/1704)