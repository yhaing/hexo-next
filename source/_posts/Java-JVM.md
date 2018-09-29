---
title: Java-JVM参数详解
date: 2018-4-10 09:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "java" #分类 
tags: #标签 
  - java
---

![](https://i.imgur.com/kb0kLNz.jpg)

<!--more-->
## JVM 基本参数

`-Xmx `: **运行最大内存**（memory maximum）

是指设定程序运行期间最大可占用的内存大小。如果程序运行需要占用更多的内存，超出了这个设置值，就会抛出OutOfMemory异常。堆的最大内存数，等同于-XX:MaxHeapSize

`-Xms`：**启动内存**(memory startup)



是指设定程序启动时占用内存大小。一般来讲，大点，程序会启动的快一点，但是也可能会导致机器暂时间变慢。堆的初始化初始化大小

`-Xmn `：(memory nursery/new)

堆中新生代初始及最大大小，如果需要进一步细化，初始化大小用-XX:NewSize，最大大小用-XX:MaxNewSize

`-Xss `：(stack size)

线程栈大小，等同于-XX:ThreadStackSize

### jvm设置的值查看

执行`ps -ef | grep tomcat`或`ps -ef | grep java`输出如下


    root  1882 1  0 8月02 ?   01:39:42 /root/SoftwareInstall/jdk/bin/java -Djava.util.logging.config.file=/usr/local/tomcat-geoserver/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -server 
    -Xms3072M -Xmx3072M -Xmn512M -Xss512k 
    -XX:+AggressiveOpts -
    .....
    org.apache.catalina.startup.Bootstrap start


如果没有设置，默认是不会有`-Xms3072M -Xmx3072M -Xmn512M -Xss512k`值打印
### docker-compose设置jvm


    environment:
      - JAVA_OPTS= '-Xmx3072m'


## JVM问题总结

geoserver添加图层预览时提示`java.lang.OutOfMemoryError: GC overhead limit exceeded`该错误

解决把`-Xmx`设置更大
