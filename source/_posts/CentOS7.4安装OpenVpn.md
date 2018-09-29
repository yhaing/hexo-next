---
title: CentOS7.4安装OpenVpn
date: 2015-1-22 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "服务器" #分类 
tags: #标签 
  - CentOS
---

![](https://i.imgur.com/QLuTZIy.jpg)

<!--more-->
## openvpn service安装与配置

### 1.下载脚本wget https://git.io/vpn -O openvpn-install.sh

    #添加执行权限
    chmod +x openvpn-install.sh
    #总结
    wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh



### 2.运行脚本./openvpn-install.sh,设置如下

    监听地址设置为空 IP address:
    Protocol:[2]TCP
    Port:1194
    不选DNS:
    client name: client_k2
    External IP : 112.74.51.136

### 3. 配置服务端vim /etc/openvpn/server.conf

    #指定ip,所以记录ip没效果屏蔽
    ;ifconfig-pool-persist ipp.txt
    ;push "redirect-gateway def1 bypass-dhcp"
    #推送服务器路由
    push "route 10.14.0.0 255.255.255.0"
    #推送k2客户端子网路由到所有客户端除了ccd里面申明了该路由的客户端
    push "route 192.168.123.0 255.255.255.0"
    #添加服务器路由，访问客户端K2的192.168.123.0子网通过网关10.14.0.2(k2客户端ip)
    route 192.168.123.0 255.255.255.0 10.14.0.2
    #添加客户端配置目录，启用之后，每个客户端必须指定ip，否正有可能访问不了其他客户端的子网
    client-config-dir ccd
    #客户端访问客户端
    client-to-client


### 4. 配置客户端路由mkdir /etc/openvpn/ccd和vim /etc/openvpn/ccd/client_k2

    #设置该客户端的vpn的ip是10.14.0.2,子网掩码必须是255.255.255.0，如果启用ccd，必须配置
    ifconfig-push 10.14.0.2 255.255.255.0
    #申明192.168.123.0是自己的子网，并且让子网也可以访问vpn服务器，申明之后不会推送该路由到该客户端
    iroute 192.168.123.0 255.255.255.0
    route 192.168.123.0 255.255.255.0

### 5.添加客户端./openvpn-install.sh

Select an option[1-4]:1 (add a new user)

client name: client_worker

    #编辑配置文件
    vim /etc/openvpn/server.conf
    #重启生效
    systemctl restart openvpn@server.service
    systemctl enable openvpn@server.service
    #注释掉客户端的
    #setenv opt block-outside-dns

### 6.下载ovpn文件，并修改配置，
注释调#setenv opt block-outside-dns

### 7.常用命令

    #重启生效
    systemctl restart openvpn@server.service
    #使能服务
    systemctl enable openvpn@server.service
    #ssh下载文件
    scp root@112.74.51.136:/root/client_xuan_ubuntu.ovpn ./

## openvpn client 安装与配置
### 1.安装

    yum update #更新
    yum install vim  #安装vim
    yum install epel-release  #添加epel源
    yum clean all # 可选
    yum update # 可选
    yum makecache # 可选
    yum install openvpn iptables-services #安装openvpn
    scp root@112.74.51.136:~/client_vm.ovpn /etc/openvpn/client/ #下载客户端配置
    #注释掉客户端的vim /etc/openvpn/client/client_vm.ovpn
    #setenv opt block-outside-dns
    #-----------------------废弃------------------------------------------------
    openvpn --daemon --cd /etc/openvpn/client --config client_vm.ovpn --log-append /etc/openvpn/openvpn.log #启动
    tail -100f /etc/openvpn/openvpn.log  #查看日志
    ps -ef | grep openvpn #查看openvpn进程
    kill <pid> #杀死进程
    #---------------------废弃结束------------------------------------------------------
    #openvpn-client启动服务，反斜杠转义字符，实际名称是openvpn-client@.service
    vim /lib/systemd/system/openvpn-client\@.service
    #修改
    ExecStart=/usr/sbin/openvpn --suppress-timestamps --nobind --config %i.conf
    #为
    ExecStart=/usr/sbin/openvpn --daemon --config %i.ovpn --log-append /etc/openvpn/openvpn.log
    #防止已经启动，@符号后面等效与%i,所以这里为客户端配置的名字
    systemctl restart openvpn-client@client_vm
    #开机启动
    systemctl enable openvpn-client@client_vm

<font size="4">*以上整理主要参照下面的文档，如涉及侵权请联系本人，进行删除。*</font><br />

## 参考

[官网](https://openvpn.net/index.php/open-source/documentation/howto.html#examples "官网")

[脚本github官网Nyr/openvpn-install](https://groups.google.com/forum/#!topic/fqlt/GUn-QNO1ZpU)

[openvpn的一个一键安装脚本“openvpn-install”让openvpn重放光彩（需翻墙）](https://groups.google.com/forum/#!topic/fqlt/GUn-QNO1ZpU)

[How to Configure OpenVPN Server on CentOS 7.3](http://gamblisfx.com/configure-openvpn-server-centos-7-3/)

[使用 OpenVPN 互联多地机房及Dokcer跨主机/机房通讯](https://www.lsproc.com/post/routing-multiple-networks-and-dockers-through-openvpn)

[扩大OpenVPN使用范围，包含服务器或客户端子网中的其他计算机](http://www.softown.cn/post/151.html)