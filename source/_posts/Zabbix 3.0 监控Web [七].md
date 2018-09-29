---
title: Zabbix 3.0 监控Web [七]
date: 2016-11-15 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

**Zabbix 默认自带一个web监控** 

我们可以从`Monitoring--->Web`进行查看 
按照前面的文章，我们在192.168.56.12上面已经开启了一个Tomcat端口为8080.如果没有的小伙伴可以阅读 [[Zabbix 3.0 生产案例 [四]](http://static.zybuluo.com/abcdocker/xbxipyrxiqyojw28gcxzvjw2/1.png)

## 一、检查
　　首先我们需要检查192.168.56.12是否有tomcat，是否可以运行。能否访问

    1.查看进程
    [root@linux-node2 ~]# ps -ef|grep java
    root   8048  25468  0 10:31 pts/000:00:00 grep --color=auto java
    root  42757  1  0 Sep26 pts/000:38:59 /usr/bin/java -Djava.util.logging.config.file=/usr/local/tomcat/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djdk.tls.ephemeralDHKeySize=2048 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8888 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=192.168.56.12 -classpath /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar -Dcatalina.base=/usr/local/tomcat -Dcatalina.home=/usr/local/tomcat -Djava.io.tmpdir=/usr/local/tomcat/temp org.apache.catalina.startup.Bootstrap start
    2.查看端口
    [root@linux-node2 ~]# lsof -i:8080
    COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
    java42757 root   48u  IPv6 379379  0t0  TCP *:webcache (LISTEN)
    3.测试是否可以访问8080端口
    [root@linux-node2 ~]# curl  -I 192.168.56.11:8080
    HTTP/1.1 200 OK
    Server: nginx/1.10.1
    Date: Mon, 10 Oct 2016 05:08:18 GMT
    Content-Type: text/html
    Content-Length: 612
    Last-Modified: Mon, 19 Sep 2016 01:59:49 GMT
    Connection: keep-alive
    ETag: "57df4695-264"
    Accept-Ranges: bytes

## 二、Zabbix Web界面配置

![](https://i.imgur.com/k3t9DCK.png)

**提示：** 监控Web 不依赖于`agent`，是`server`直接发送请求的

![](https://i.imgur.com/djYf00S.png)

![](https://i.imgur.com/iXJ3j6I.png)

**提示：** 这里名字叫做Web场景，因为我们可以设置触发上面3个选项后，才进行报警

![](https://i.imgur.com/xVZT1p6.png)

![](https://i.imgur.com/FccOix1.png)

**提示：** 字符串里面可以添加一些字符串，当请求下来有这个字符串就是正常，没有就是不正常。但是最常用的还是状态

![](https://i.imgur.com/4Z6dLne.png)

然后我们选择`Add`

![](https://i.imgur.com/M4ZZ7Ws.png)

　　比较坑的一点是，我们新添加了一个Web监控。zabbix默认没有给我们安装触发器 
　　 
![](https://i.imgur.com/3D4Q3WS.png)

## 三、触发器添加
![](https://i.imgur.com/EPTz5vx.png)

**Web监控中默认不含有触发器，所以需要手动添加** 

点右上角，进行创建触发器 

![](https://i.imgur.com/XWW8TRK.png)

![](https://i.imgur.com/zGY9S93.png)

![](https://i.imgur.com/fMhFbmK.png)

## 四、触发器报警测试

1、停掉tomcat，要想返回值不是200 停掉tomcat是最简单的

    [root@linux-node2 ~]# /usr/local/tomcat/bin/shutdown.sh 
    Using CATALINA_BASE:   /usr/local/tomcat
    Using CATALINA_HOME:   /usr/local/tomcat
    Using CATALINA_TMPDIR: /usr/local/tomcat/temp
    Using JRE_HOME:/usr
    Using CLASSPATH:   /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
    检查
    [root@linux-node2 ~]# ps aux|grep tomcat
    root   8723  0.0  0.0 112648   976 pts/1R+   12:21   0:00 grep --color=auto tomcat

报警如下： 

![](https://i.imgur.com/ji62dXY.png)

![](https://i.imgur.com/YvAIT7B.png)

![](https://i.imgur.com/k2ucRXV.png)

回复如上 
邮件报警设置可以访问 [Zabbix 3.0 生产案例 [五]](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.abcdocker.com/abcdocker/1496) 
我们还可以优化动作[Actions] 

![](https://i.imgur.com/XHyfWtp.png)

　　Zabbix 就是一个万能的什么都可以监控，只要我们有key。什么都可以监控 
key我们可以使用脚本，程序等等等 

转自：[Zabbix 3.0 监控Web [七]](https://www.abcdocker.com/abcdocker/1501)