---
title: Zabbix字符集乱码及Centos7补全设置
date: 2016-11-10 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

## Centos补全安装软件包

    [root@linux-node1 ~]# yum install -y bash-completion

**从新打开窗口即可**

操作：

    1. 找到本地C:\Windows\Fonts\simkai.ttf（楷体）上传到服务器zabbix网站目录fonts目录下。
    [root@localhost /]# whereis zabbix
    zabbix: /usr/lib/zabbix /etc/zabbix /usr/share/zabbix
    [root@localhost /]# cd /usr/share/zabbix
    [root@localhost zabbix]# ll |grep fonts
    drwxr-xr-x.  3 root root75 Jun 12 14:04 fonts
    [root@localhost zabbix]# cd fonts/
    [root@localhost fonts]# ll
    total 30176
    drwxr-xr-x. 2 root root   26 Jun 12 14:01 fonts_bak
    -rw-r--r--. 1 root root   720012 Jun 12 14:03 graphfont.ttf
    -rw-r--r--. 1 root root 11785184 Jun 11  2009 simkai.ttf
    -rw-r--r--. 1 root root 18387092 Jun 12 14:04 uming.ttf
    [root@localhost fonts]# 
    2. 修改zabbix php配置文件
    [root@localhost /]# find -name defines.inc.php
    ./usr/share/zabbix/include/defines.inc.php
    [root@localhost fonts]# cd /usr/share//zabbix/
    [root@localhost zabbix]# ll |grep include
    drwxr-xr-x.  4 root root  4096 Jun 12 14:37 include
    #从网上抄的，不适合本机
    sed -i 's/DejaVuSans/simkai/g' ./include/defines.inc.php
    #自己修改的，做了两次，后发现界面上文字没有了。
    sed -i 's/graphfont/simkai/g' ./include/defines.inc.php
    sed -i 's/fonts/simkai/g' ./include/defines.inc.php
    #检查defines.inc.php文件
    [root@localhost zabbix]# vim defines.inc.php
    #查找到“simkai”关键字，修改ZBX_FONTPATH'（红色标记部分）
    // the maximum period to display history data for the latest data and item overview pages in seconds
    // by default set to 86400 seconds (24 hours)
    define('ZBX_HISTORY_PERIOD', 86400);
    define('ZBX_WIDGET_ROWS', 20);
    define('ZBX_FONTPATH',  realpath('/usr/share/zabbix/fonts/')); // where to search for 
    font (GD > 2.0.18)
    define('ZBX_GRAPH_FONT_NAME',   'simkai'); // font file name
    /simkai
    define('ZBX_FLAG_DISCOVERY_NORMAL', 0x0);
    define('ZBX_FLAG_DISCOVERY_RULE',   0x1);
    define('ZBX_FLAG_DISCOVERY_PROTOTYPE',  0x2);
    define('ZBX_FLAG_DISCOVERY_CREATED',0x4);
    define('EXTACK_OPTION_ALL', 0);
    define('EXTACK_OPTION_UNACK',   1);
    define('EXTACK_OPTION_BOTH',2);
    define('TRIGGERS_OPTION_RECENT_PROBLEM',1);
    define('TRIGGERS_OPTION_ALL',   2);
    define('TRIGGERS_OPTION_IN_PROBLEM',3);
    define('ZBX_ACK_STS_ANY',   1);
    define('ZBX_ACK_STS_WITH_UNACK',2);
    define('ZBX_ACK_STS_WITH_LAST_UNACK',   3);
    define('EVENTS_OPTION_NOEVENT', 1);
    define('EVENTS_OPTION_ALL', 2);
    define('EVENTS_OPTION_NOT_ACK', 3);
    define('ZBX_FONT_NAME', 'simkai');
    define('ZBX_AUTH_INTERNAL', 0);
    define('ZBX_AUTH_LDAP', 1);
    define('ZBX_AUTH_HTTP', 2);
    #重启zabbix服务
    service zabbix-server restart

**提示：如果我们找不到配置文件可以使用以下方法**

    [root@linux-node1 ~]# find / -type f -name "defines.inc.php"
    /usr/share/zabbix/include/defines.inc.php

**将字体导入到**`/usr/share/zabbix/fonts`

**效果图如下**

![](https://i.imgur.com/7NZjNbk.png)

　　　图一，修改前 

![](https://i.imgur.com/txPbTOm.png)

　　　图一，修改后

转载自：[Zabbix字符集乱码及Centos7补全设置](https://www.abcdocker.com/abcdocker/1489)
