---
title: OSSFS实现阿里云OSS文件系统数据共享
date: 2015-1-24 09:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "阿里云" #分类 
tags: #标签 
  - 阿里云
---

![](https://i.imgur.com/8q05EYs.jpg)

**[阿里云ESC服务器挂载 OSS 文件系统](https://github.com/aliyun/ossfs/blob/master/README-CN.md)**

ossfs 能让您在Linux/Mac OS X 系统中把Aliyun OSS bucket 挂载到本地文件 系统中，您能够便捷的通过本地文件系统操作OSS 上的对象，实现数据的共享。

阿里云oss官方：ossfs挂载，您可以理解为把挂载的bucket当做一个ecs目录来操作的，存储文件到挂载的bucket中是占用的这个bucket的内存，不会占用您ecs的内存。


## 安装


下载文件[ossfs_1.80.3_centos7.0_x86_64.rpm](https://github.com/aliyun/ossfs/releases)到阿里云

安装`sudo yum localinstall ossfs_1.80.3_centos7.0_x86_64.rpm`

写入oss配置`echo my-bucket:my-access-key-id:my-access-key-secret > /etc/passwd-ossfs`,例：

    echo ossfs-xuan:LTAIw5M5SHnIoNcm:ci1Oj7*******ZqDziBj > /etc/passwd-ossfs

更改配置文件权限`chmod 640 /etc/passwd-ossfs`

创建挂载目录`mkdir /ossfs`

挂载`ossfs ossfs-xuan /ossfs -ourl=oss-cn-shenzhen-internal.aliyuncs.com`

## 额外的命令

    #允许linux其他用户对改oss文件系统进行操作
    ossfs ossfs-xuan /ossfs -ourl=oss-cn-shenzhen-internal.aliyuncs.com -o allow_other
    #卸载挂载oss目录
    umount /ossfs

## 可能出现的错误

`InvalidBucketName`错误可以看出BucketName重复了

    ossfs: bad request
    <?xml version="1.0" encoding="UTF-8"?>
    <Error>
      <Code>InvalidBucketName</Code>
      <Message>The specified bucket is not valid.</Message>
      <RequestId>5A93BFD701A3E286AC09FDDD</RequestId>
      <HostId>ossfs-xuan.ossfs-xuan.oss-cn-shenzhen-internal.aliyuncs.com</HostId>
      <BucketName>ossfs-xuan.ossfs-xuan</BucketName>
    </Error>

解决：`-ourl=oss-cn-shenzhen-internal.aliyuncs.com`不需要带`BucketName`