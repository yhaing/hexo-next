---
title: Zabbix-3.0.X 安装Graphtree
date: 2016-12-5 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/8NOSdbF.png)

<!--more-->

# Zabbix-3.0.X 安装Graphtree

### zabbix

本文转载[http://blog.csdn.net/wh211212/article/details/52735180](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://blog.csdn.net/wh211212/article/details/52735180)

Zabbix中，想要集中展示图像，唯一的选择是`screen`，后来`zatree`解决了`screen`的问题，但性能不够好。`Graphtree` 由`OneOaaS`开发并开源出来，用来解决Zabbix的图形展示问题，性能较好。

**提示：zatree不支持3.x和3.2暂时只支持2.4**

![](https://i.imgur.com/312evDz.png)

## 一、Graphtree功能概述
> ▲ 集中展示所有分组设备
> 
> ▲ 集中展示一个分组图像
> 
> ▲ 集中展示一个设备图像
> 
> ▲ 展示设备下的Application
> 
> ▲ 展示每个应用下的图像
> 
> ▲ 展示每个应用下的日志
> 
> ▲ 对原声无图的监控项进行绘图

**注意事项：** 主机和组级别下，默认只显示系统初始的图形

## 二、Zabbix版本要求：3.0.x
提示：暂时只支持3.0版本，根据测试不支持3.2版本

### 1、插件安装

Zabbix-web目录 
提示：如果是yum安装并且是centos7目录会在`/usr/share/zabbix`可以使用find进行查找

`cd /usr/local/nginx/html/zabbix`

下载Graphtree补丁包

`wget https://raw.githubusercontent.com/OneOaaS/graphtrees/master/graphtree3-0-1.patch`

安装Linux下打补丁命令patch

`yum -y install patch`

打补丁

`patch -Np0 < graphtree3-0-1.patch`

![](https://i.imgur.com/mIRiKjr.png)

## 三、Graphtree效果图
### 1、删除提示信息

    vim /usr/local/nginx/html/zabbix/graphtree.right.php
    根据自己的路径进行修改
    d7d   #删除344-350行

### 2、重启载入Zabbix-web，可以看到Graphtree已出效果

![](https://i.imgur.com/5abjRCU.png)

转自：[Zabbix-3.0.X 安装Graphtree](https://www.abcdocker.com/abcdocker/2226)