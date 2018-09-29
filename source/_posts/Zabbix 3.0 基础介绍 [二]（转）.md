---
title: Zabbix 3.0 部署监控 [二]
date: 2016-10-11 09:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->
# 一、添加监控主机及设置
## 1.创建主机

![](https://i.imgur.com/wXtti2z.png)


![](https://i.imgur.com/kACn1M5.png)

Agent可以干一些SNMP无法干的事情，例如自定义监控项 
snmp相关文章：[http://www.abcdocker.com/abcdocker/1376](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.abcdocker.com/abcdocker/1376)

![](https://i.imgur.com/LFIPaOX.png)

这里我们先不着急点`add`，还需要设置其他选项 


![](https://i.imgur.com/4u2NHLG.png)


### 点击监控模板
 
　　zabbix监控是由`监控项`组成（`cpu`使用率监控就是一个`监控项/内存使用率`就是一个监控项），如果是`100`台服务器就需要监控`模板`了。只需要将监控项和模板`关联`起来即可 
举个例子：我们上面主机使用的是SNMP，就可以直接搜索`SNMP`。提示：有的模板需要自己定义 

![](https://i.imgur.com/73QMhPM.png)

**温馨提示**：请点击下面的小`add` 然后在点大的。否则会出现问题哦 

![](https://i.imgur.com/3hudHYL.png)

`IPMI`如果有的话，需要在这里写上`用户名`和`密码` 

![](https://i.imgur.com/9KbrIww.png)

宏定义，这个宏其实就是一个变量。我们给可以给变量附一个值 

![](https://i.imgur.com/LL4rzh4.png)

　　因为我们设置的是`SNMP`，`SNMP`有一个团体名。并且可以设置定义 
　　团体名是中间的`abcdocker`，具体的可以看[http://www.abcdocker.com/abcdocker/1376](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.abcdocker.com/abcdocker/1376)

    [root@localhost ~]# cat /etc/snmp/snmpd.conf
    rocommunity abcdocker 192.168.56.11

![](https://i.imgur.com/AE1kmcp.png)

值：`{$SNMP_COMMUNITY} `

![](https://i.imgur.com/Rr1RTL5.png)

主机资产设置分为3中 
1、关闭 Disabled 
2、手动 Manual 
3、自动 Automatic （自动代表的是你在定义监控项的时候，他有一个小箭头，勾上之后监控项的值就会填写在这里） 
　　　我们这设置好模板就可以选择`add`了 

![](https://i.imgur.com/dKJRUO7.png)

等`SNMP`变绿就好了 

![](https://i.imgur.com/ZOsjvyj.png)

　　现在的状态是用`SNMP`进行监控了，我们只是添加了一个`SNMP OS LINUX`的模板，但是出现了4个。这4个链接。可以和多个`模板`连起来用 

![](https://i.imgur.com/Y8asoOq.png)

进入监控项，下面这个菜单是过滤搜索用的 

![](https://i.imgur.com/jGamdQU.png)

下面全都是模板 
　　我们可以随便点击一个，这里我们新建一个监控项 

![](https://i.imgur.com/PU2i90h.png)

### 点击创建 
类型选择
 
　　**Zabbix agent 被动 **

　**　Zabbix agent (active主动模式) **

　　**Simple check 简单检测 **

　　**SNMPv1 agent ......**


![](https://i.imgur.com/HQy4VCm.png)

在Key这行点击Select 可以进行选择 

![](https://i.imgur.com/2TxJOc1.png)

我们随便选择一个，例如agent.version。查看agent的版本 
Numeric是无符号整数型 

![](https://i.imgur.com/wZIZn8Q.png)

## 2.图形说明
`Configuration----hosts----Graphs` 

![](https://i.imgur.com/9cWv17r.png)

绘图靠的是`监控项`，我们可以随便打开一个看看 

![](https://i.imgur.com/te8GA7w.png)

颜色等都是可以随意设置

## 3、聚合图形screens设置

![](https://i.imgur.com/U4ouREh.png)

**提示**：因为咱们用的版本是3.0当2.4的时候需要在`Configuration----`下面来创建`screens`

<font size="5">**创建Screens**</font><br /> 

![](https://i.imgur.com/rQqdIh7.png)

我们创建一个`2*2` 命名为`test screens`的`screens` 

![](https://i.imgur.com/Bx4w2Rf.png)

然后我们点进去 
点击`编辑` 

![](https://i.imgur.com/kMkoNsK.png)

点击`Change`进行设置 

![](https://i.imgur.com/K4sQRIt.png)

![](https://i.imgur.com/2y8NeW0.png)

多添加几个之后就是以下结果 

![](https://i.imgur.com/IAvmsAj.png)

# 二、监控案例[自定义监控项]
**例如**：我们自己添加一个监控项来进行监控当前的活动连接数 
`nginx`安装地址：[http://www.abcdocker.com/abcdocker/1376](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.abcdocker.com/abcdocker/1376) 
Nginx状态模块配置如下，过于简单不说了


    [root@localhost ~]# cat /usr/local/nginx/conf/nginx.conf
    listen   8080;
    location /status {
    stub_status on;
    access_log off;
    allow 192.168.56.0/24;
    deny all;
    }

修改`nginx`端口并重启 
测试：`http://192.168.56.11:8080/status` 

![](https://i.imgur.com/YizZlbM.png)


**解释说明**：使用zabbix来监控活动连接数，通过status状态模块为前提 ,我们现在命令取出我们想要的值，例如：

    
    [root@localhost ~]# curl -s http://192.168.56.11:8080/status|grep Active|awk -F "[ ]" '{print $3}'
    1

因为我们是监控他的活动连接数，他的活动连接数为`1`


    [root@linux-node1 ~]# vim /etc/zabbix/zabbix_agentd.conf 
    Include=/etc/zabbix/zabbix_agentd.d/

提示： 如果想要加自定义监控项，不要在配置文件中写入，可以在`Include`里面定义的目录写上 ,只要我们写在Include目录下，都可以识别到

    [root@linux-node1 ~]# cd /etc/zabbix/zabbix_agentd.d/
    [root@linux-node1 zabbix_agentd.d]# ls
    userparameter_mysql.conf
    #默认有一个MySQL的，我们可以参考MySQL的进行操作
    UserParameter=mysql.ping,HOME=/var/lib/zabbix mysqladmin ping | grep -c alive
    #提示，前面是key的名称 后面的key的命令
    UserParameter=mysql.version,mysql -V

我们自己编辑一个文件

    [root@linux-node1 zabbix_agentd.d]# cat nginx.conf
    UserParameter=nginx.active,/usr/bin/curl -s http://192.168.56.11:8080/status|grep Active|awk -F "[ ]" '{print $3}'
    提示，此处配置文件的名字可以随便起

　　如果是多个命令可以写一个`脚本`，命令最好写`绝对路径`！这个过程其实就是我们定义监控的过程，前面是`key`的名字，后面是命令 
修改完配置文件之后需要重启`zabbix-agent`

    [root@linux-node1 zabbix_agentd.d]# systemctl restart zabbix-agent

　　配置完成之后先在`server`端测试，是否可以获取到`agent`上的值。不要着急添加 ,我们现在只用了1台服务器，本机是server也是agent。然后使用`zabbix-get`进行`测试`

    [root@linux-node1 zabbix_agentd.d]# yum list|grep zabbix
    zabbix-agent.x86_64 3.0.4-1.el7@zabbix  
    zabbix-release.noarch   3.0-1.el7  installed
    zabbix-server-mysql.x86_64  3.0.4-1.el7@zabbix  
    zabbix-web.noarch   3.0.4-1.el7@zabbix  
    zabbix-web-mysql.noarch 3.0.4-1.el7@zabbix  
    python-pyzabbix.noarch  0.7.3-2.el7epel 
    uwsgi-stats-pusher-zabbix.x86_642.0.13.1-2.el7 epel 
    zabbix-get.x86_64   3.0.4-1.el7zabbix 
    查看zabbix_get
    [root@linux-node1 zabbix_agentd.d]# yum install -y zabbix-get

`zabbix-get`使用参数如下：

    [root@linux-node1 zabbix_agentd.d]# zabbix_get -s 192.168.56.11 -p 10050 -k "nginx.active"
    -s 指定我们要查看的服务器
    -p 端口，可以不加。默认是10050
    -k 监控项的名称（根据上面的配置来定义的）
    更多参数：zabbix_get --help

<font size="5">**错误案例：**</font><br /> 

**如果出现如下错误，大致意思是拒绝连接**

    [root@linux-node1 zabbix_agentd.d]# zabbix_get -s 192.168.56.11 -p 10050 -k "nginx.active"
    zabbix_get [24234]: Check access restrictions in Zabbix agent configuration

**解决方法：**

    [root@linux-node1 ~]# vim /etc/zabbix/zabbix_agentd.conf 
    Server= 192.168.56.11

因为我们当时只允许本机127.0.0.1进行连接。所以会出现这样问题

    [root@linux-node1 ~]# systemctl restart zabbix-agent

修改完配置文件都要`重启` 
**提示：** zabbix-agent的配置文件中指定允许那个server连接，那个才可以进行连接。

    [root@linux-node1 zabbix_agentd.d]# zabbix_get -s 192.168.56.11 -p 10050 -k "nginx.active"
    1

正确结果如上！ 
提示：如果在`zabbix-agent`上面修改了，还需要在网页上进行修改 

![](https://i.imgur.com/Jxf9phF.png)

在`/etc/zabbix/zabbix-agent.conf`上面指定的`Server`是谁，就只会允许谁通过。如果有多个`ip`可以使用逗号进行分割

<font size="5">**添加item**</font><br /> 

![](https://i.imgur.com/XfOXKfJ.png)

找到一个安装`zabbix-agent`，点击 

![](https://i.imgur.com/qvmIqOc.png)

点击`items` 

![](https://i.imgur.com/S1YCrHW.png)

然后添加`Create item`（创建item） 

![](https://i.imgur.com/uo2dbwl.png)


![](https://i.imgur.com/RwEiwRj.png)


`Data type：`数据类型，这里我们选择Decimal。其他的基本上用不上
 
`Units：`单位 超过1千就写成1k了。 可以在这里做一个单位的设置。默认就可以
 
`Use custom multiplier：`如果这里面设置了一个数，得出来的结果都需要乘以文本框设定的值 
![](https://i.imgur.com/B52CbQ2.png)



`Update interval（in sec）: `监控项刷新时间间隔（一般不要低于60秒）
 
`Custom intervals: `创建时间间隔（例如：1点-7点每隔多少秒进行监控）格式大致为：周，时，分 

![](https://i.imgur.com/up6padf.png)


`History storage period:` 历史数据存储时间（根据业务来设置，默认就可以）
 
`Trend storage period:` 趋势图要保存多久
 
`New application:` 监控项的组 

`application:` 选择一个监控项组 

`Populates host inventory field:` 资产，可以设定一个监控项。把获取的值设置在资产上面 

![](https://i.imgur.com/bSUfFot.png)


描述！必须要写。 要不你就是不负责任

![](https://i.imgur.com/oL0Ybzo.png) 

<font size="5">**添加自定义监控项小结：**</font><br />  
　　　1、添加用户自定义参数（在`/etc/zabbix/zabbix.agent.d/`定义了一个`nginx.conf`步骤如上）
 
　　　2、重启`zabbix-agent`
 
　　　3、在`Server`端使用`zabbix_get`测试`获取`（命令如上）
 
　　　4、在web界面创建`item`（监控项）
 
　　
<font size="5">**自定义图形**</font><br /> 

![](https://i.imgur.com/5HriOtl.png)

`Name：`名字 

`Width：`宽度 

`Height：`高度
 
`Graph type：`图形类型
 
其他**默认**即可 

![](https://i.imgur.com/wqAxrE6.png)

然后我们点击`Add`添加`Items`监控项，找到我们刚刚设置的服务器 


![](https://i.imgur.com/IinJoVX.png)


然后找到我们刚刚添加的`监控项` 

![](https://i.imgur.com/0ZrDTPc.png)

还可以选择颜色，添加其他的很多设置。不细说 

![](https://i.imgur.com/cWxIVaR.png)

　　点击`Prewview`可以进行预览，如果出现字符乱码可以阅读我们另一篇文章（zabbix默认不支持中文）,确定没有问题，选择下方`Add`即可 

![](https://i.imgur.com/cBKA75W.png)

出现我们添加的 

![](https://i.imgur.com/vLGECJ2.png)

需要在`Monitoring--->Graphs--->`选择我们添加的主机即可 
接下来我们需要进行`测试`： 
测试前： 

![](https://i.imgur.com/pm0cBcj.png)


使用`ab`测试工具进行测试，设置`100万`并发进行访问


    [root@linux-node1 ~]# ab -c 1000 -n 1000000 http://192.168.56.11:8080/
    This is ApacheBench, Version 2.3 <$Revision: 1430300 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/
    Benchmarking 192.168.56.11 (be patient)

测试后： 

![](https://i.imgur.com/Qz26Jcf.png)

我们可以查看zabbix监控图标 

![](https://i.imgur.com/yrZHIeJ.png)


我们中间设置了间隔60秒，说明每隔`60秒`我们进行获取一次,我们可以设置它的方式显示 
找到`Graph`选择类型，`Stacked`是堆叠显示，其他的大家可以自行百度。不细说 
堆叠显示如下： 

![](https://i.imgur.com/sUIs3O0.png)


如果我们想加多个图形都显示在一张图上，可以进行如下操作 

![](https://i.imgur.com/APrvwHu.png)


找到`Graphs` 

![](https://i.imgur.com/ooOFZNn.png)


找到我们设置的图形 

![](https://i.imgur.com/JZuXDar.png)


点击添加即可

我们可以让多个图标显示在一个图片上 

![](https://i.imgur.com/bWEv3xY.png)

点击我们创建一个聚合图形（`screens`）

![](https://i.imgur.com/Rt6xqBu.png) 

点击进去 

![](https://i.imgur.com/aO4Kpk4.png)

点击编辑 

![](https://i.imgur.com/mrIoY6n.png)


选择`item`添加的地方，因为上面创建聚合图形的时候我们选择了2X2 所以这里会显示2个 

![](https://i.imgur.com/FQMHST9.png)

找到相对应的添加即可 
我们可以多添加几个

![](https://i.imgur.com/mGQs3PL.png)

结果如上图显示 
除了显示图片还可以显示其他内容 

![](https://i.imgur.com/xQP2yB1.png)


    Action log：日志
    Clock：时间
    Data overview：数据概述
    Graph：图形
    History of events：历史事件
    Host group issues：主机组问题
    Host issues：主机问题
    Hosts info：主机信息
    Plain text：文本
    Map：架构图
    Screen：屏幕
    Server info：服务器信息
    Simple graph：简单的图
    Simple graph prototype：简单的原型图
    System status：系统状态
    Triggers info：触发器信息
    Tiggers overview：概述
    URL：URL地址


<font size="5">**例如我们输入一个URL：**</font><br /> 



![](https://i.imgur.com/QW3BePX.png)
![](https://i.imgur.com/QYbUlBT.png)


我们还可以自定义一个`Maps`，一张架构图。操作如下：

![](https://i.imgur.com/s1pZDMQ.png) 


第二步：选择编辑`Edit map` 

![](https://i.imgur.com/pVOVGk8.png)


因为他默认图片比较小，我们可以点击下方，进行调整图片大小。

![](https://i.imgur.com/yjCeI3v.png)


点击右上角`编辑`，然后我们点中图中的服务器即可 

![](https://i.imgur.com/OtZD5xQ.png)


我们模拟有2台服务器 

![](https://i.imgur.com/O796AlV.png)


然后我们选中新添加的服务器进行修改

![](https://i.imgur.com/nShhJ0F.png) 

点击`Apply`就可以了。 
按住`Ctrl`点中`zabbix server`和另一台服务器 

![](https://i.imgur.com/8yxlYhw.png)

然后我们点击左上方的`Link`：他们就连接起来了 

![](https://i.imgur.com/NCvBZlW.png)


温馨提示：修改完成后需要点击保存[`update`]如果不点后果就是从新在做一遍~

![](https://i.imgur.com/dQHTj6a.png)

未完！

转载自：[Zabbix 3.0 部署监控 [二] | abcdocker运维博客](https://www.abcdocker.com/abcdocker/1453) 