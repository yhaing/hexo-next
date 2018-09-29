---
title: CentOS7修改网卡为eth0
date: 2015-1-22 09:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "服务器" #分类 
tags: #标签 
  - CentOS
---

![](https://i.imgur.com/zJGIIlO.jpg)

<!--more-->
使用CentOS-7最直观的变化就是服务管理了。这里介绍一下。

**services使用了systemd来代替sysvinit管理**

> systemd是Linux下的一种init软件，由Lennart Poettering带头开发，并在LGPL 2.1及其后续版本许可证下开源发布。其开发目标是提供更优秀的框架以表示系统服务间的依赖关系，并依此实现系统初始化时服务的并行启动，同时达到降低Shell的系统开销的效果，最终代替现在常用的System V与BSD风格init程序。

> 与多数发行版使用的System V风格init相比，systemd采用了以下新技术：
> 采用Socket激活式与总线激活式服务，以提高相互依赖的各服务的并行运行性能；
> 用cgroups代替PID来追踪进程，以此即使是两次fork之后生成的守护进程也不会脱离systemd的控制。
> 从设计构思上说，由于systemd使用了cgroup与fanotify等组件以实现其特性，所以只适用于Linux。
> systemd的服务管理程序：
> systemctl是主要的工具，它融合之前service和chkconfig的功能于一体。可以使用它永久性或只在当前会话中启用/禁用服务。

    启动一个服务：systemctl start postfix.service
    关闭一个服务：systemctl stop postfix.service
    重启一个服务：systemctl restart postfix.service
    显示一个服务的状态：systemctl status postfix.service
    在开机时启用一个服务：systemctl enable postfix.service
    在开机时禁用一个服务：systemctl disable postfix.service
    查看服务是否开机启动：systemctl is-enabled postfix.service;echo $?
    查看已启动的服务列表：systemctl list-unit-files|grep enabled
    

## CentOS7修改网卡为eth0
### 编辑网卡信息
    [root@linux-node2~]# cd /etc/sysconfig/network-scripts/  #进入网卡目录
    [root@linux-node2network-scripts]# mv ifcfg-eno16777728 ifcfg-eth0  #重命名网卡名称
    [root@linux-node2network-scripts]# cat ifcfg-eth0  #编辑网卡信息
    TYPE=Ethernet
    BOOTPROTO=static
    DEFROUTE=yes
    PEERDNS=yes
    PEERROUTES=yes
    IPV4_FAILURE_FATAL=no
    NAME=eth0  #name修改为eth0
    ONBOOT=yes
    IPADDR=192.168.56.12
    NETMASK=255.255.255.0
    GATEWAY=192.168.56.2
    DNS1=192.168.56.2
### 修改grub
    [root@linux-node2~]# cat /etc/sysconfig/grub  #编辑内核信息,添加红色字段的
    GRUB_TIMEOUT=5
    GRUB_DEFAULT=saved
    GRUB_DISABLE_SUBMENU=true
    GRUB_TERMINAL_OUTPUT="console"
    GRUB_CMDLINE_LINUX="crashkernel=auto rhgb net.ifnames=0 biosdevname=0 quiet"
    GRUB_DISABLE_RECOVERY="true"
    [root@linux-node2~]# grub2-mkconfig -o /boot/grub2/grub.cfg  #生成启动菜单
    Generatinggrub configuration file ...
    Foundlinux image: /boot/vmlinuz-3.10.0-229.el7.x86_64
    Foundinitrd image: /boot/initramfs-3.10.0-229.el7.x86_64.img
    Foundlinux image: /boot/vmlinuz-0-rescue-1100f7e6c97d4afaad2e396403ba7f61
    Foundinitrd image: /boot/initramfs-0-rescue-1100f7e6c97d4afaad2e396403ba7f61.img
    Done
也可以在开机启动加载安装系统界面设置。
### 验证是否修改成功
    [root@linux-node2~]# reboot  #必须重启系统生效
    [root@linux-node2~]# yum install net-tools #默认centos7不支持ifconfig 需要看装net-tools包
    [root@linux-node2~]# ifconfig eth0  #在次查看网卡信息
    eth0:flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
    inet 192.168.56.12  netmask 255.255.255.0  broadcast 192.168.56.255
    inet6 fe80::20c:29ff:fe5c:7bb1  prefixlen 64 scopeid 0x20<link>
    ether 00:0c:29:5c:7b:b1  txqueuelen 1000  (Ethernet)
    RX packets 152  bytes 14503 (14.1 KiB)
    RX errors 0  dropped 0 overruns 0  frame 0
    TX packets 98  bytes 14402 (14.0 KiB)
    TX errors 0  dropped 0 overruns 0  carrier 0 collisions 0
### 设置主机名解析
    [root@linux-node1 ~]# cat /etc/hosts
    
    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
    
    ::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
    
    192.168.56.11 linux-node1 linux-node1.example.com
    
    192.168.56.12 linux-node2 linux-node2.example.com
### centos 7 修改主机名的方法
hostnamectl命令
在7版本中，hostname有三种形式
静态(Static host name)
动态(Transient/dynamic host name)
别名(Pretty host name)

查询主机名

    hostnamectl或hostctl status 查询主机名
    hostnamectl status [--static|--transient|--pretty]

修改hostname

    hostnamectl set-hostname servername [--static|--transient|--pretty]

删除hostname

    hostnamectl set-hostname ""
    hostnamectl set-hostname "" --static
    hostnamectl set-hostname "" --pretty

修改配置文件

    hostname  name
    vim /etc/hostname 

通过nmtui修改，之后重启hostnamed

    systemctl restart systemd-hostnamed
通过nmcui修改，之后重启hostnamed

    nmcli general hostname servername
    systemctl restart systemd-hostnamed
    
### 安装EPEL仓库和常用命令
    [root@linux-node1 ~]# rpm -ivh http://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm
    
    [root@linux-node1 ~]# yum install -y net-tools vim lrzsz tree screen lsof tcpdump
### 关闭NetworkManager和防火墙
    [root@linux-node1 ~]# systemctl stop firewalld  #关闭防火墙
    [root@linux-node1 ~]# systemctl disable firewalld   #设置开机不启动
    
    [root@linux-node1 ~]# systemctl stop NetworkManager
### 关闭SELinux
    [root@linux-node1 ~]# vim /etc/sysconfig/selinux
    
    SELINUX=disabled #修改为disabled
检查结果如下

    [root@linux-node1 ~]# getsebool 
    
    getsebool:  SELinux is disabled
### 更新系统并重启
    [root@linux-node1 ~]# yum update -y && reboot

## centos7设置开机脚本

新建开机脚本`vim /root/Dropbox/save/bootstartscript.sh`


    #添加开机启动脚本
    #开机启动dropbox
    dropbox start -d

添加开机脚本到启动文件`vim /etc/rc.d/rc.local`


    #开机启动脚本
    /bin/sh /root/Dropbox/save/bootstartscript.sh


设置启动脚本生效

    chmod +x /etc/rc.d/rc.local



