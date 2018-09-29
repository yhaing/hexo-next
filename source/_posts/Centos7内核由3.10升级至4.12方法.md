---
title: Centos 7/6 内核版本由3.10.0 升级至 4.12.4方法
date: 2015-01-21 12:34:14
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "服务器" #分类 
tags: #标签 
  - CentOS
---

![](https://i.imgur.com/xmziP0K.jpg)

<!--more-->
##  【写在前面】

公司打算上Docker服务，目前需要安装运行环境，Docker新的功能除了需要Centos 7系统之外，内核的版本高低也决定着使用的效果，所以在此记录下系统内核版本升级过程。
**
注：对于线上环境的内核版本还需要根据实际情况谨慎选择，越新的版本未来可能遇到的问题越多，此文只是记录升级方法而已。**
##  【文章内容】
**关于内核版本的定义：**

版本性质：主分支ml(mainline)，稳定版(stable)，长期维护版lt(longterm)


版本命名格式为 “A.B.C”：

**数字 A 是内核版本号**：版本号只有在代码和内核的概念有重大改变的时候才会改变，历史上有两次变化：
第一次是1994年的 1.0 版，第二次是1996年的 2.0 版，第三次是2011年的 3.0 版发布，但这次在内核的概念上并没有发生大的变化

**数字 B 是内核主版本号：**主版本号根据传统的奇-偶系统版本编号来分配：奇数为开发版，偶数为稳定版

**数字 C 是内核次版本号：**次版本号是无论在内核增加安全补丁、修复bug、实现新的特性或者驱动时都会改变
### 一、查看那系统内核版本
    
    uname -r
    3.10.0-514.el7.x86_64
    cat /etc/redhat-release 
    CentOS Linux release 7.3.1611 (Core)

    
### 二、升级内核

Centos 6和Centos 7的升级方法类似，只不过就是选择的YUM源或者rpm包不同罢了，下面主要是Centos 7的安装方法，中间也会有对于Centos 6 升级的方法提示。

**方法一：**

Centos 6 YUM源：http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm
Centos 7 YUM源：http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

升级内核需要先导入elrepo的key，然后安装elrepo的yum源：

    rpm -import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

仓库启用后，你可以使用下面的命令列出可用的内核相关包，如下图：

    yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

![](https://i.imgur.com/XdxdnmC.jpg)

上图可以看出，长期维护版本lt为4.4，最新主线稳定版ml为4.12，我们需要安装最新的主线稳定内核，使用如下命令：(以后这台机器升级内核直接运行这句就可升级为最新稳定版)

    yum -y --enablerepo=elrepo-kernel install kernel-ml.x86_64 kernel-ml-devel.x86_64 

**方法二：**

对于一些无法上网的服务器，或者需要安装指定版本内核的需求，我们可以把kernel image的rpm包下载下来安装，下载地址如下：

    下载指定版本 kernel： http://rpm.pbone.net/index.php3?stat=3&limit=1&srodzaj=3&dl=40&search=kernel
    下载指定版本 kernel-devel：http://rpm.pbone.net/index.php3?stat=3&limit=1&srodzaj=3&dl=40&search=kernel-devel
    
    官方 Centos 6: http://elrepo.org/linux/kernel/el6/x86_64/RPMS/
    
    官方 Centos 7: http://elrepo.org/linux/kernel/el7/x86_64/RPMS/


![](https://i.imgur.com/6XuTzZM.jpg)


将rpm包下载上传到服务器上，使用下面的命令安装即可：

    yum -y install kernel-ml-devel-4.12.4-1.el7.elrepo.x86_64.rpm 
    yum -y install kernel-ml-4.12.4-1.el7.elrepo.x86_64.rpm

**方法三：**

还可以通过源码包编译安装，这种方式可定制性强，但也比较复杂，有需要的可自行查找资料安装，下面只给出各系统版本内核源码包的下载地址：https://www.kernel.org/pub/linux/kernel/

### 三、修改grub中默认的内核版本

内核升级完毕后，目前内核还是默认的版本，如果此时直接执行reboot命令，重启后使用的内核版本还是默认的3.10，不会使用新的4.12.4，首先，我们可以通过命令查看默认启动顺序：

    
    awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg
    
    CentOS Linux (4.12.4-1.el7.elrepo.x86_64) 7 (Core)
    
    CentOS Linux (3.10.0-514.el7.x86_64) 7 (Core)
    
    CentOS Linux (0-rescue-a43cc2091b4557f1fd10a52ccffa5db2) 7 (Core)


由上面可以看出新内核(4.12.4)目前位置在0，原来的内核(3.10.0)目前位置在1，所以如果想生效最新的内核，还需要我们修改内核的启动顺序为0：

```vim /etc/default/grub```

![](https://i.imgur.com/rdO1xZ3.jpg)

注：Centos 6 更改的文件相同，使用命令确定新内核位置后，然后将参数default更改为0即可。

接着运行grub2-mkconfig命令来重新创建内核配置，如下：

    grub2-mkconfig -o /boot/grub2/grub.cfg

### 四、重启系统并查看系统内核

    reboot

系统启动完毕后，可以通过命令查看系统的内核版本，如下：

    uname -r
    4.12.4-1.el7.elrepo.x86_64

到此，Centos 7内核升级完毕。
