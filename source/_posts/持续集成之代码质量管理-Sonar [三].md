---
title: 持续集成之代码质量管理-Sonar [三]
date: 2017-3-21 11:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "Jenkins" #分类 
tags: #标签 
  - Jenkins
---

![](https://i.imgur.com/m3ECCmT.jpg)

<!--more-->

> 摘要
> 
> Sonar 是一个用于代码质量管理的开放平台。通过插件机制，Sonar 可以集成不同的测试工具，代码分析工具，以及持续集成工具。与持续集成工具（例如 Hudson/Jenkins 等）不同，Sonar 并不是简单地把不同的代码检查工具结果（例如 FindBugs，PMD 等）直接显示在 Web 页面上，而是通过不同的插件对这些结果进行再加工处理，通过量化的方式度量代码质量的变化，从而可以方便地对不同规模和种类的工程进行代码质量管理。

## Sonar介绍

Sonar 是一个用于代码质量管理的开放平台。通过插件机制，Sonar可以集成不同的测试工具，代码分析工具，以及持续集成工具。与持续集成工具（例如 `Hudson/Jenkins` 等）不同，Sonar 并不是简单地把不同的代码检查工具结果（例如 `FindBugs，PMD` 等）直接显示在 `Web` 页面上，而是通过不同的插件对这些结果进行再加工处理，通过量化的方式度量代码质量的变化，从而可以方便地对不同规模和种类的工程进行代码质量管理。 
　　在对其他工具的支持方面，Sonar 不仅提供了对 `IDE` 的支持，可以在 `Eclipse`和 `IntelliJ IDEA` 这些工具里联机查看结果；同时 Sonar 还对大量的持续集成工具提供了接口支持，可以很方便地在持续集成中使用 Sonar。 
　　此外，Sonar 的插件还可以对 `Java` 以外的其他编程语言提供支持，对国际化以及报告文档化也有良好的支持。

## Sonar部署

　　Sonar的相关下载和文档可以在下面的链接中找到：[http://www.sonarqube.org/downloads/](http://www.sonarqube.org/downloads/)。需要注意最新版的Sonar需要至少JDK 1.8及以上版本。

　上篇文章我们已经可以成功的使用git进行拉去，Sonar的功能就是来检查代码是否有BUG。除了检查代码是否有bug还有其他的功能，比如说：你的代码注释率是多少，代码有一些建议，编写语法的建议。所以我们叫质量管理

Sonar还可以给代码打分，并且引用了技术宅的功能（告诉你有很多地方没改）

### Sonar部署

    [root@linux-node1 ~]# yum install -y java-1.8.0
    [root@linux-node1 ~]# cd /usr/local/src
    软件包我们通过wget或者下载，rz上传到服务器
    #软件包下载：https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-5.6.zip
    [root@linux-node1 src]# unzip sonarqube-5.6.zip
    [root@linux-node1 src]# mv sonarqube-5.6 /usr/local/
    [root@linux-node1 src]# ln -s /usr/local/sonarqube-5.6/ /usr/local/sonarqube

### 准备Sonar数据库 

如果没有数据库请执行`yum install -y mariadb mariadb-server`

    [root@linux-node1 ~]# systemctl start mariadb
    [root@linux-node1 ~]# systemctl enable mariadb
    Created symlink from /etc/systemd/system/multi-user.target.wants/mariadb.service to /usr/lib/systemd/system/mariadb.service.
    [root@linux-node1 ~]# mysql_secure_installation
    [root@linux-node1 ~]# mysql -uroot -p123456

**特别提示：** 

![](https://i.imgur.com/WrF7tle.png)

sonar好像不支持`mysql 5.5`，所以如果看日志出现以上error 请安装`mysql 5.6` 或者更高版本 
[http://blog.csdn.net/onothing12345/article/details/49910087](http://blog.csdn.net/onothing12345/article/details/49910087)

**执行sql语句**

    mysql> CREATE DATABASE sonar CHARACTER SET utf8 COLLATE utf8_general_ci;
    mysql> GRANT ALL ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar@pw';
    mysql> GRANT ALL ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar@pw';
    mysql> FLUSH PRIVILEGES;

### 配置Sonar

    [root@linux-node1 ~]#  cd /usr/local/sonarqube/conf/
    [root@linux-node1 conf]# ls
    sonar.properties  wrapper.conf

编写配置文件，修改数据库配置

    [root@linux-node1 conf]# vim sonar.properties
    #我们只需要去配置文件里面修改数据库的认证即可
     14 sonar.jdbc.username=sonar#数据库用户
     15 sonar.jdbc.password=sonar@pw #数据库密码
     23 sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance

**配置Java访问数据库驱动(可选)** 
　　默认情况Sonar有自带的嵌入的数据库，那么你如果使用类是Oracle数据库，必须手动复制驱动类到`${SONAR_HOME}/extensions/jdbc-driver/oracle/`目录下，其它支持的数据库默认提供了驱动。其它数据库的配置可以参考官方文档： 
[http://docs.sonarqube.org/display/HOME/SonarQube+Platform](http://docs.sonarqube.org/display/HOME/SonarQube+Platform)

### 启动Sonar 

　　你可以在Sonar的配置文件来配置Sonar Web监听的IP地址和端口，默认是9000端口。

    [root@linux-node1 conf]# vim sonar.properties
     99 #sonar.web.host=0.0.0.0
    106 #sonar.web.port=9000

启动命令如下：

    [root@linux-node1 ~]# /usr/local/sonarqube/bin/linux-x86-64/sonar.sh start
    Starting SonarQube...
    Started SonarQube.

如果有什么问题可以看一下日志[`/usr/local/sonarqube/logs/sonar.log`]

**检查是否有相应的端口**

    [root@linux-node1 ~]# netstat -lntup
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address   Foreign Address State   PID/Program name
    tcp0  0 127.0.0.1:8080  0.0.0.0:*   LISTEN  2239/unicorn master
    tcp0  0 0.0.0.0:80  0.0.0.0:*   LISTEN  505/nginx: master p
    tcp0  0 0.0.0.0:22  0.0.0.0:*   LISTEN  569/sshd
    tcp0  0 127.0.0.1:250.0.0.0:*   LISTEN  971/master
    tcp0  0 127.0.0.1:43163 0.0.0.0:*   LISTEN  5205/java
    tcp0  0 0.0.0.0:80600.0.0.0:*   LISTEN  505/nginx: master p
    tcp0  0 127.0.0.1:32000 0.0.0.0:*   LISTEN  4925/java
    tcp0  0 0.0.0.0:43044   0.0.0.0:*   LISTEN  4952/java
    tcp0  0 0.0.0.0:33350   0.0.0.0:*   LISTEN  5205/java
    tcp0  0 0.0.0.0:90000.0.0.0:*   LISTEN  5011/java
    tcp0  0 0.0.0.0:33385   0.0.0.0:*   LISTEN  5011/java
    tcp0  0 127.0.0.1:9001  0.0.0.0:*   LISTEN  4952/java
    tcp6   0  0 :::3306 :::*LISTEN  4658/mysqld
    tcp6   0  0 :::34993:::*LISTEN  2348/java
    tcp6   0  0 :::8081 :::*LISTEN  2348/java
    tcp6   0  0 :::22   :::*LISTEN  569/sshd
    tcp6   0  0 ::1:25  :::*LISTEN  971/master
    udp6   0  0 :::33848:::*2348/java
    udp6   0  0 :::5353 :::*2348/java
    #端口是9000哦！

### Web登陆：IP:9000 

![](https://i.imgur.com/W6TEPwu.png)

**提示**： 

sonar跟jenkins类似，也是以插件为主 
sonar安装插件有2种方式：第一种将插件下载完存放在sonar的插件目录，第二种使用web界面来使用安装 
存放插件路径[`/usr/local/sonarqube/extensions/plugins/`]

### 安装中文插件 

登陆：用户名：`admin` 密码：`admin` 

![](https://i.imgur.com/3qYDQbq.png)

![](https://i.imgur.com/MoEVBlL.png)

![](https://i.imgur.com/zS5Eku0.png)

![](https://i.imgur.com/LsCoNMh.png)

需要重启才会生效

生效后如下图： 

![](https://i.imgur.com/9gBz6ki.png)

**我们在安装一个php语言 **

![](https://i.imgur.com/5gk5HQ3.png)

**温馨提示：**如果下载不下来我们直接去`github`进行下载，因为我们这个插件都是使用wget进行下载的 

![](https://i.imgur.com/aMxHuJI.png)

我们现在只能使用java的jar包和php，因为我们只安装了java和php的语言插件。如果想使用Python的程序，就需要安装Python的语言插件

`Sonar 插件--->语言插件 （分析什么语言，你就需要安装什么语言的插件）`

Sonar通过SonarQube Scanner（扫描器）来对代码进行分析 
官方文档：[http://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner](http://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner)

下载扫描器插件

    [root@linux-node1 ~]# wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-2.8.zip
    [root@linux-node1 ~]# unzip sonar-scanner-2.8.zip
    [root@linux-node1 ~]# mv sonar-scanner-2.8 /usr/local/
    [root@linux-node1 ~]# ln -s /usr/local/sonar-scanner-2.8/ /usr/local/sonar-scanner

我们要将扫描器和sonar关联起来

    [root@linux-node1 ~]# cd /usr/local/sonar-scanner
    [root@linux-node1 sonar-scanner]# ls
    bin  conf  lib
    [root@linux-node1 sonar-scanner]# cd conf/
    [root@linux-node1 conf]# ls
    sonar-scanner.properties
    [root@linux-node1 conf]# vim sonar-scanner.properties
    sonar.host.url=http://localhost:9000#sonar地址
    sonar.sourceEncoding=UTF-8  #字符集
    sonar.jdbc.username=sonar#数据库账号
    sonar.jdbc.password=sonar@pw  #数据库密码
    sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&amp;characterEncoding=utf8#数据库连接地址
    #打开注释即可

我们现在需要找一个代码进行分析。

sonar插件提供了一个代码的库 
github:[https://github.com/SonarSource/sonar-examples](https://github.com/SonarSource/sonar-examples) 
我们下载软件包：[https://codeload.github.com/SonarSource/sonar-scanning-examples/zip/master](https://codeload.github.com/SonarSource/sonar-scanning-examples/zip/master)

解压

    [root@linux-node1 src]# unzip sonar-examples-master.zip
    [root@linux-node1 php]# cd sonar-examples-master/projects/languages/php
    [root@linux-node1 php]# cd php-sonar-runner-unit-tests/
    [root@linux-node1 php-sonar-runner-unit-tests]# ll
    total 8
    -rw-r--r-- 1 root root 647 Dec 14 09:57 README.md
    drwxr-xr-x 2 root root  51 Dec 14 09:57 reports
    -rw-r--r-- 1 root root 346 Dec 14 09:57 sonar-project.properties
    drwxr-xr-x 3 root root  31 Dec 14 09:57 src
    drwxr-xr-x 2 root root  25 Dec 14 09:57 tests
    #这里就是PHP的目录

**配置文件解释：** 

如果你想让我扫描，就需要在代码路径下放一个配置文件

    [root@linux-node1 php-sonar-runner-unit-tests]# cat sonar-project.properties
    sonar.projectKey=org.sonarqube:php-ut-sq-scanner  #Key
    sonar.projectName=PHP :: PHPUnit :: SonarQube Scanner   #这里的名称会显示在一会的web界面上
    sonar.projectVersion=1.0#版本，这里的版本一会也会显示在web界面上
    sonar.sources=src  #软件包存放路径
    sonar.tests=tests
    sonar.language=php   #语言
    sonar.sourceEncoding=UTF-8 #字体
    # Reusing PHPUnit reports
    sonar.php.coverage.reportPath=reports/phpunit.coverage.xml
    sonar.php.tests.reportPath=reports/phpunit.xml

**也就是说在项目里面必须有这个配置文件才可以进行扫描**

**扫描** 

提示：需要在项目文件里面进行执行

    [root@linux-node1 php-sonar-runner-unit-tests]# /usr/local/sonar-scanner/bin/sonar-scanner
    INFO: Scanner configuration file: /usr/local/sonar-scanner/conf/sonar-scanner.properties
    INFO: Project root configuration file: /usr/local/src/sonar-examples-master/projects/languages/php/php-sonar-runner-unit-tests/sonar-project.properties
    INFO: SonarQube Scanner 2.8
    INFO: Java 1.8.0_111 Oracle Corporation (64-bit)
    INFO: Linux 3.10.0-514.2.2.el7.x86_64 amd64
    INFO: User cache: /root/.sonar/cache
    INFO: Load global repositories
    INFO: Load global repositories (done) | time=211ms
    WARN: Property 'sonar.jdbc.url' is not supported any more. It will be ignored. There is no longer any DB connection to the SQ database.
    WARN: Property 'sonar.jdbc.username' is not supported any more. It will be ignored. There is no longer any DB connection to the SQ database.
    WARN: Property 'sonar.jdbc.password' is not supported any more. It will be ignored. There is no longer any DB connection to the SQ database.
    INFO: User cache: /root/.sonar/cache
    INFO: Load plugins index
    INFO: Load plugins index (done) | time=3ms
    INFO: Download sonar-csharp-plugin-5.0.jar
    INFO: Download sonar-java-plugin-3.13.1.jar
    INFO: Download sonar-l10n-zh-plugin-1.11.jar
    INFO: Plugin [l10nzh] defines 'l10nen' as base plugin. This metadata can be removed from manifest of l10n plugins since version 5.2.
    INFO: Download sonar-scm-git-plugin-1.2.jar
    INFO: Download sonar-php-plugin-2.9.1.1705.jar
    INFO: Download sonar-scm-svn-plugin-1.3.jar
    INFO: Download sonar-javascript-plugin-2.11.jar
    INFO: SonarQube server 5.6
    INFO: Default locale: "en_US", source code encoding: "UTF-8"
    INFO: Process project properties
    INFO: Load project repositories
    .................................................
    .................................................

**提示：**我们什么都不指定就会在当面目录下扫描`sonar-project.properties`文件，根据配置文件进行扫描工作。扫描之后我们在web界面上就可以看到代码的扫描结果

这里的名字，版本 都是在`sonar-project.properties`文件中定义的 

![](https://i.imgur.com/xRSPTdM.png)

质量阈帮我们设定好一个阈值，超过相应的阈值就算有`bug` 

![](https://i.imgur.com/e5tZlHW.png)

为了让jenkins可以在构建项目的时候执行sonar，所以我们需要在jenkins上安装插件 

![](https://i.imgur.com/RtRWvkz.png)

现在就可以进行配置，让`jenkins`和`sonar`结合在一起。这样我们构建项目的时候就会进行代码检测


![](https://i.imgur.com/gqA21hZ.png)

![](https://i.imgur.com/VqwohTk.png)

点击保存

![](https://i.imgur.com/NkVfVjA.png)

配置 

![](https://i.imgur.com/x2BHnJq.png)

编辑我们的项目，选择最下放。找到构建 

![](https://i.imgur.com/glMVbO6.png)

对PHP文件进行复制

    [root@linux-node1 php-sonar-runner-unit-tests]# cat /usr/local/src/sonar-examples-master/projects/languages/php/php-sonar-runner-unit-tests/sonar-project.properties
    sonar.projectKey=org.sonarqube:php-ut-sq-scanner
    sonar.projectName=PHP :: PHPUnit :: SonarQube Scanner
    sonar.projectVersion=1.0
    sonar.sources=src
    sonar.tests=tests
    sonar.language=php
    sonar.sourceEncoding=UTF-8
    # Reusing PHPUnit reports
    sonar.php.coverage.reportPath=reports/phpunit.coverage.xml
    sonar.php.tests.reportPath=reports/phpunit.xml

![](https://i.imgur.com/RDOgcvH.png)

Analysis properties 分析的参数

填写完毕后，我们点击保存 

![](https://i.imgur.com/pkvnNRl.png)

我们选择立即构建 

![](https://i.imgur.com/WWdd7bE.png)

**提示：**此时的SonarQube是无法点击的

点击`Console Output`可以查看构建输出的内容 

![](https://i.imgur.com/sXO1FHq.png)

#提示：只要没有error就可以

![](https://i.imgur.com/efmTIre.png)

构建完成后，我们发现这里的SonarQube可以点击，我们点击SonarQube就会链接到192.168.56.11:9000 就是代码查看器的地址 

![](https://i.imgur.com/BmxEddC.png)

现在我们已经做到了可以在git上进行拉取代码。并进行检测

**我们还可以配置一个构建失败发送邮箱：** 

![](https://i.imgur.com/49XPvZd.png)

在我们项目里面设置构建后操作，选择`E-mail Notification` 

![](https://i.imgur.com/XwFVdda.png)

温馨提示：使用163邮箱发送的通知被163服务器退回了，因此我将设置在jenkins的邮箱改成了QQ邮箱

QQ：邮箱需要设置如下： 

![](https://i.imgur.com/9roQMP3.png)

**1、需要开启POPE3/SMTP服务 **

**2、在jenkins上配置的密码我们需要点击生成授权码进行使用**

QQ邮件默认会收到如下提示： 

![](https://i.imgur.com/7351peX.png)

当再次构件成功时，邮件内容如下： 

![](https://i.imgur.com/DMVVLqr.png)

转自：[持续集成之代码质量管理-Sonar [三]](https://www.abcdocker.com/abcdocker/2053)