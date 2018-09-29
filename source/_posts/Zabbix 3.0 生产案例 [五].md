---
title: Zabbix 3.0 生产案例 [五]
date: 2016-11-12 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

上面我们说到了监控TCP和Nginx状态，但是光是监控是没有任何作用的。监控完我们不知道跟没监控没啥区别，下面我们进行`监控项`的讲解

## 1.触发器

### 首先我们给Nginx添加触发器 
1.选择`Configuration--->Hosts`
 
2.找到我们相对应的主机进入
 
3.选择主机中的`Triggers`--->`添加(Create trigger)`
 
![](https://i.imgur.com/xcBXHXp.png)

我们设置一个事件 

![](https://i.imgur.com/k0iy6sC.png)

![](https://i.imgur.com/UGPmKyD.png)

我们选择`Insert`，然后选择`Add`即可
 
4.查看报警状态 

　因为我们设置的级别大于1就报警，默认Nginx是0，随便访问以下就是1.所以肯定就会报警。报警邮件可以根据我们前面 [[Zabbix 3.0 部署监控 [三]]](http://static.zybuluo.com/abcdocker/nesqv40waf6l3gdk171juv2y/5.png)文章进行设置
 
　报警邮件如下： 

![](https://i.imgur.com/zMv137e.png)

我们可以查看这个事件的相关过程 

![](https://i.imgur.com/QSQwji0.png)

**以上就是我们添加的一个触发器报警步骤**

![](https://i.imgur.com/LmkZYln.png)

　Zabbix默认触发器的预值比较低，我们需要调大。这个在面试过程中会被问到

**我们进行修改默认模板 **

路径下图： 

![](https://i.imgur.com/vpkELqt.png)

![](https://i.imgur.com/IZe1iWy.png)

我们可以看到默认是大于300进行报警,我们点进去修改即可 

![](https://i.imgur.com/KvIhC9J.png)

　　根据实际情况进行修改，我们设置600即可。同时触发器支持多个条件进行报警，如or all等，只需要在上面的值后面继续添加即可。
 
　**我们修改完之后**

![](https://i.imgur.com/dnwF23N.png)　　

　　还有一个有警告显示磁盘不够，因为是虚拟机我们不予理会，我们可以查看到恢复之后的邮件

## 2.脚本发送邮件

**提示：** Zabbix邮件报警是3.0才有的，以前不支持用户名密码。所以早期都是使用脚本进行发送邮件报警。 
　由于时间关系我们就不进行写了请下载发送邮件的`python`脚本： 
链接：[http://pan.baidu.com/s/1gfkGrgZ](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://pan.baidu.com/s/1gfkGrgZ) 密码：6bsh

脚本注释：

    Python脚本中三个相关的参数
    receiver = sys.argv[1]
    #收件人地址
    subject = sys.argv[2]
    #发送邮件的主题
    mailbody =  sys.argv[3]
    #发送邮件的内容
    smtpserver = 'smtp.exmail.qq.com'  
    #邮件服务器地址，本脚本使用的是企业邮箱
    username = 'username'  
    #用户名
    password = 'password' 
    #密码
    sender = username
    #发送人名称

我们如果要写一个发送邮件的脚本，需要支持三个参数
 
**1、收件人**
 
**2、标题**

**3、内容** 
　

## 自定义告警脚本

　我们也可以使用`shell`写一个最简单的 
脚本存放路径：我们可以在配置文件中查看

    [root@linux-node1 web]# vim /etc/zabbix/zabbix_server.conf 
    AlertScriptsPath=/usr/lib/zabbix/alertscripts

提示： 这行配置文件定义了邮件脚本的存放路径，因为它默认会从`usr/lib/zabbix/alertscripts`查找邮件脚本

    [root@linux-node1 web]# vim /usr/lib/zabbix/alertscripts/sms.sh
    #!/bin/bash
    ALTER_TO=$1
    ALTER_TITLE=$2
    ALTER_BODY=$3
    echo $ALTER_TO >> /tmp/sls.log
    echo $ALTER_TITLE >> /tmp/sms.log
    echo $ALTER_BODY >> /tmp/sms.log

我们可以写完之后进行检测，如果这里有信息说明已经调用这个脚本。 如果我们有短信通道将里面的内容换一下即可，短信通道都是有售后的

    修改权限
    [root@linux-node1 web]# chmod +x /usr/lib/zabbix/alertscripts/sms.sh
    [root@linux-node1 web]# ll /usr/lib/zabbix/alertscripts/sms.sh
    -rwxr-xr-x 1 root root 152 Oct  8 20:26 /usr/lib/zabbix/alertscripts/sms.sh

　　我们写的脚本是短信报警，首先你需要有一个短信通道，我们可以使用阿里云大鱼，本次我们使用文件追加的形式来模拟. 
　　

## Zabbix页面设置

![](https://i.imgur.com/XgmUwbW.png)

点击右上角创建报警介质 

![](https://i.imgur.com/bc606cn.png)

点击最下面的Add 

![](https://i.imgur.com/NS8zuVb.png)

![](https://i.imgur.com/9WWzreK.png)

![](https://i.imgur.com/pccnHXZ.png)

**提示：**先点击小的`Update`在点最下面的`Update`
 
**我们还需要修改报警媒介**

![](https://i.imgur.com/8maCQej.png)

找到相对应的用户，点击。 

![](https://i.imgur.com/ZQRqZgJ.png)

![](https://i.imgur.com/RZ1JjqV.png)

　　**接下来就需要我们触发报警了 **

![](https://i.imgur.com/AculFPz.png)

上面我们设置的连接数是大于1，所以我们多刷新几次就可以了 

![](https://i.imgur.com/3sP2IDz.png)

这里显示发送完成，我们去日志进行查看 

![](https://i.imgur.com/OMBQtvx.png)

>  13122323232  为发送的手机号
>  PROBLEM：   为主题信息 Nginx Active  监控项
>  Original........：为故障信息，2代表连接数是2

**提示：** 因为中国的短信收费是70个字符2毛，字母也算是。所以我们发送邮件的报警信息就需要简介明了一点

优化图如下：

![](https://i.imgur.com/qRHL6IX.png)

修改后如下： 

![](https://i.imgur.com/YshYqFV.png)

　　设置完成之后最好数一下，不要超过70个字符 

![](https://i.imgur.com/PMWn8RW.png)

[http://www.alidayu.com/](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.alidayu.com/) 

有兴趣的同学可以自己了解一下阿里大鱼，可以提供短信通道、语音、验证码等业务。 

![](https://i.imgur.com/gQyv6yN.png)

短信通道比较出名的几款产品： 
　　亿美软通 阿里大鱼 腾讯云也有

微信报警
　　短信报警和邮件报警已经说过了，我们简单的说一下微信报警 

![](https://i.imgur.com/6y54pzs.png)

　　因为在很早之前就说过，个人服务号和订阅号不支持直接跟订阅用户进行沟通。如果是企业号可以直接获取到一个类似key，拿着这个key直接curl就可以了发了。 具体内容可以进行百度或者谷哥搜索。

**扩展：** 除了以上三种报警，还有`钉钉报警`以前还有`QQ报警`、`飞信报警`，但是现在已经不开源了 

**提示：** 上面那三行最好不要删除，在生产环境中追加到一个文件中。记录发送邮件的信息

转载自：[Zabbix 3.0 生产案例 [五]](https://www.abcdocker.com/abcdocker/1496)