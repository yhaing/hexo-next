---
title: ZABBIX 忘记登录密码
date: 2017-7-29 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/HNonS5h.jpg)

<!--more-->

> 摘要
> 
> 有些童鞋会忘记zabbix的登陆密码，今天给大家写一篇找回登陆密码~



做运维由于账号比较多，脑子容易瓦特. 结果忘记自己的zabbix登录密码下面是找回登录密码的例子

未修改之前(忘记登录密码)

    [root@abcdocker ~]# mysql -uroot -p -e "select * from zabbix.users\G"
    Enter password: 
    *************************** 1. row ***************************
    userid: 1
     alias: Admin
      name: Zabbix
       surname: Administrator
    passwd: ab66b6e18854fa4d45499d0a04a47b64
       url: 
     autologin: 1
    autologout: 0
      lang: en_GB
       refresh: 30
      type: 3
     theme: default
    attempt_failed: 0
    attempt_ip: 14.130.112.2
     attempt_clock: 1501141026
     rows_per_page: 50

**登录MySQL 修改密码**

    [root@abcdocker ~]# mysql -uroot -p
    由于密码是md5加密的，我们可以查看默认的zabbix密码的md5
    mysql> use zabbix;
    mysql> update users set passwd='5fce1b3e34b520afeffb37ce08c7cd66' where userid='1';
    Query OK, 1 row affected (0.01 sec)
    Rows matched: 1  Changed: 1  Warnings: 0
    解释：5fce1b3e34b520afeffb37ce08c7cd66  = zabbix
    因为zabbix默认密码就是zabbix

**登录 Web** 

用户名：Admin 

密码：zabbix

![](https://i.imgur.com/3Us6Jn9.png)

提示**：登陆上请马上修改密码**
 
![](https://i.imgur.com/vsggy5L.png)

![](https://i.imgur.com/E7BXHtC.png)

完！

转自：[ZABBIX 忘记登录密码](https://www.abcdocker.com/abcdocker/2659)