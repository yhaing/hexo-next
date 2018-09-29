---
title: CentOS7.4安装GlusterFS
date: 2015-1-23 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "服务器" #分类 
tags: #标签 
  - CentOS
---

![](https://i.imgur.com/cptQfLu.jpg)

<!--more-->
## 介绍

[Gluster](https://www.gluster.org/)是一个大尺度文件系统。

### 主要功能
**简单卷**

    distribute volume 分布式卷，两台主机的磁盘融合一个磁盘
    stripe volume 条带卷，一个文件分成数据块存储到不同的地方
    replica volume 复制卷，一个文件分别保存到两台主机

**复合卷**

1+2，1+3，2+3，1+2+3

## 总结常用命令

    gluster peer status #查看集群各主机连接状态
    gluster volume list#查看挂载卷信息
    gluster volume list #查看卷列表
    #创建挂在卷，force忽略在root目录创建挂在卷的警告
    gluster volume create swarm-volume replica 3 worker:/xuan/docker/gluster-volume home:/xuan/docker/gluster-volume xuanps:/xuan/docker/gluster-volume force
    gluster volume start swarm-volume #启动
    gluster volume stop swarm-volume #停止
    gluster volume delete swarm-volume #删除 ，了文件还会保留
    #挂载本地目录到glusterfs卷（swarm-volume），在本地目录添加的会自动同步到其他挂载卷
    #eg在本机mnt添加文件，其他volume-name目录也会添加mount [-参数] [设备名称] [挂载点]
    mount -t glusterfs worker:/swarm-volume /mnt/
    umount worker:/swarm-volume  #卸载了就不会同步了
    #重置，删除所有数据
    systemctl stop glusterd
    rm -rf /var/lib/glusterd/
    systemctl start glusterd
    #删除节点
    gluster peer detach home

## 安装

准备工作：

三台局域网主机（centos7 修改主机名 ）

<table><tr><th> hostname</th><th>ip</th><th>备注</th></tr><tr><td>xuanps</td><td>left-aligned</td><td>10.14.0.1</td></tr><tr><td> worker</td><td>centered</td><td>10.14.0.4</td></tr><tr><td>home</td><td>right-aligned</td><td>10.14.0.5</td></tr></table>


三台都需要安装GlusterFS

    #搜索glusterfs可安装的版本
    yum search centos-release-gluster
    #安装最新长期稳定版本(Long Term Stable)的gluster软件
    yum -y install centos-release-gluster
    #安装glusterfs-server
    yum --enablerepo=centos-gluster*-test install glusterfs-server
    glusterfs -V #测试
    systemctl enable glusterd #开机启动
    systemctl start glusterd #启动
    systemctl status glusterd #查看是否正常运行
    #修改hosts不然不能通过主机名连接到对方
    vim /etc/hosts
    #----------三台都要添加如下设置--------------------------
    10.14.0.1 xuanps
    10.14.0.4 worker
    10.14.0.5 home
    #------------------------------------------------------
    #从xuanps上执行下面两条，其他主机不用执行
    gluster peer probe worker
    gluster peer probe home
    #三台都执行该命令是否都是connected
    gluster peer status
    #查看挂载卷信息
    gluster volume info
    #创建挂在卷，force忽略在root目录创建挂在卷的警告
    gluster volume create volume-name replica 3 worker:/xuan/docker/gluster-volume/test home:/xuan/docker/gluster-volume/test xuanps:/xuan/docker/gluster-volume/test force
    #启动
    gluster volume start volume-name
    #启动nfs同步，测试需验证，这里要不要开启
    gluster volume set volume-name nfs.disable off
    #挂载本地目录到glusterfs卷（volume-name），在本地目录添加的会自动同步到其他挂载卷
    #eg在本机mnt添加文件，其他volume-name目录也会添加
    mount -t glusterfs worker:/volume-name /mnt/

<font size="4">*以上整理主要参照下面的文档，如涉及侵权请联系本人，进行删除。*</font><br />
    
## 参考


[官方文档](http://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/)

[centos官方安装手册](https://wiki.centos.org/SpecialInterestGroup/Storage/gluster-Quickstart)

[基于 GlusterFS 实现 Docker 集群的分布式存储](https://www.ibm.com/developerworks/cn/opensource/os-cn-glusterfs-docker-volume/index.html)