---
title: Zabbix-3.2.3实现微信（WeChat）告警
date: 2016-12-10 10:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "zabbix" #分类 
tags: #标签 
  - zabbix
---

![](https://i.imgur.com/HNonS5h.jpg)

<!--more-->

> 摘要
> 
> Zabbix可以通过多种方式把告警信息发送到指定人，常用的有邮件，短信报警方式，但是越来越多的企业开始使用zabbix结合微信作为主要的告警方式，这样可以及时有效的把告警信息推送到接收人，方便告警的及时处理。


## Zabbix-3.2.3实现微信（WeChat）告警

　Zabbix可以通过多种方式把告警信息发送到指定人，常用的有邮件，短信报警方式，但是越来越多的企业开始使用zabbix结合微信作为主要的告警方式，这样可以及时有效的把告警信息推送到接收人，方便告警的及时处理。

关于邮件报警可以参考：[Zabbix Web 邮件报警](https://www.abcdocker.com/abcdocker/1704)

## 一、微信企业号申请
地址： [https://qy.weixin.qq.com/](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=https://qy.weixin.qq.com/)

### 第一步注册 

![](https://i.imgur.com/U5HuvbE.png)

**提示：这里简单的说一下，微信企业号和微信公众号是不一样的！**

![](https://i.imgur.com/SIdNbvs.png)

到邮件查看邮件，继续下一步 

![](https://i.imgur.com/7JIT89m.png)

提示一下：注册以后就不可以修改微信号类型 

![](https://i.imgur.com/OQxYuIQ.png)

我们选择注册团队 

![](https://i.imgur.com/Yq58MU3.png)

由于我已经注册了，下一步就不继续操作了 

![](https://i.imgur.com/FDejvSZ.png)

## 二、配置微信企业号
当我们设置完微信号的信息之后，请继续跟我操作 

![](https://i.imgur.com/1jfCkLL.png)

我们点击通讯录-->创建子部门-->运维组 

![](https://i.imgur.com/JXeWkUG.png)

提示： 我们需要记录运维组的ID，用于脚本接收报警 

![](https://i.imgur.com/8I22VQT.png)

我们点击运维-->添加成员 

![](https://i.imgur.com/A1PGqwc.png)

关于认证可以参考官方说明： 

![](https://i.imgur.com/IrbL6s1.png)

![](https://i.imgur.com/iMYQqTV.png)

我们可以使用扫描二维码认证或者邀请认证 

![](https://i.imgur.com/5uphI1w.png)

我们点击创建应用 

![](https://i.imgur.com/9aZyYlt.png)

选择消息型 

![](https://i.imgur.com/AFaAEmi.png)

设置组合用户，将运维整个组添加进去 

![](https://i.imgur.com/87Roqju.png)

设置完成之后如下图所示！ 
**提示：我们需要记录应用ID，在接收邮件时会使用** 

![](https://i.imgur.com/t6Br864.png)

设置权限，让运维组有查看的选项。管理员可以不进行设置 

![](https://i.imgur.com/kDhcLqV.png)

**需要确定管理员有权限使用应用发送消息，需要管理员的CorpID和Sercrt。（重要）**

### 准备事项：

微信企业号 

企业号已经被部门成员关注 

企业号有一个可以发送消息的应用，一个授权管理员，可以使用应用给成员发送消息

### 需要得到的信息

> 成员账号
> 
> 组织部门ID
> 
> 应用ID
> 
> CorpID和Secret

## 三、修改Zabbix.conf
    [root@abcdocker ~]# grep alertscripts /etc/zabbix/zabbix_server.conf 
    AlertScriptsPath=/usr/lib/zabbix/alertscripts
    我们设置zabbix默认脚本路径，这样在web端就可以获取到脚本

## 四、设置python脚本
#安装simplejson

    wget https://pypi.python.org/packages/f0/07/26b519e6ebb03c2a74989f7571e6ae6b82e9d7d81b8de6fcdbfc643c7b58/simplejson-3.8.2.tar.gz
    tar zxvf simplejson-3.8.2.tar.gz && cd simplejson-3.8.2
    python setup.py build
    python setup.py install

下载wechat.py脚本

    git clone https://github.com/X-Mars/Zabbix-Alert-WeChat.git
    cp Zabbix-Alert-WeChat/wechat.py /usr/lib/zabbix/alertscripts/
    cd /usr/lib/zabbix/alertscripts/
    chmod +x wechat.py && chown zabbix:zabbix wechat.py

**提示：这里需要修改py脚本**
看注释，这就不解释了

    [root@abcdocker ~]# cat /usr/lib/zabbix/alertscripts/wechat.py 
    #!/usr/bin/python
    #_*_coding:utf-8 _*_
    import urllib,urllib2
    import json
    import sys
    import simplejson
    reload(sys)
    sys.setdefaultencoding('utf-8')
    def gettoken(corpid,corpsecret):
    gettoken_url = 'https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=' + corpid + '&corpsecret=' + corpsecret
    print  gettoken_url
    try:
    token_file = urllib2.urlopen(gettoken_url)
    except urllib2.HTTPError as e:
    print e.code
    print e.read().decode("utf8")
    sys.exit()
    token_data = token_file.read().decode('utf-8')
    token_json = json.loads(token_data)
    token_json.keys()
    token = token_json['access_token']
    return token
    def senddata(access_token,user,subject,content):
    send_url = 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=' + access_token
    send_values = {
    "touser":user,#企业号中的用户帐号，在zabbix用户Media中配置，如果配置不正常，将按部门发送。
    "toparty":"2",#企业号中的部门id。
    "msgtype":"text", #消息类型。
    "agentid":"2",#企业号中的应用id。
    "text":{
    "content":subject + '\n' + content
       },
    "safe":"0"
    }
    #send_data = json.dumps(send_values, ensure_ascii=False)
    send_data = simplejson.dumps(send_values, ensure_ascii=False).encode('utf-8')
    send_request = urllib2.Request(send_url, send_data)
    response = json.loads(urllib2.urlopen(send_request).read())
    print str(response)
    if __name__ == '__main__':
    user = str(sys.argv[1]) #zabbix传过来的第一个参数
    subject = str(sys.argv[2])  #zabbix传过来的第二个参数
    content = str(sys.argv[3])  #zabbix传过来的第三个参数
    corpid =  '11111111111111'   #CorpID是企业号的标识
    corpsecret = '222222222222222222'  #corpsecretSecret是管理组凭证密钥
    accesstoken = gettoken(corpid,corpsecret)
    senddata(accesstoken,user,subject,content)

执行py脚本，进行测试

    [root@abcdocker alertscripts]# ./wechat.py www www 123
    https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=wx6dadb9cc293b793e&corpsecret=JjesoeixbFt6dDur7_eXtamVBx2SjPBuXMQ0Jte3YLkz8l-VBnr0JvU12P0kvpGJ
    {u'invaliduser': u'all user invalid', u'errcode': 0, u'errmsg': u'ok'}

![](https://i.imgur.com/nsqaDhn.png)

## 五、zabbix web 界面配置
创建报警媒介 

![](https://i.imgur.com/MSPKLMF.png)

![](https://i.imgur.com/BIEqkbr.png)

创建报警用户 

![](https://i.imgur.com/n2twuWo.png)

![](https://i.imgur.com/UvpCbY7.png)

这里填写运维组ID 

![](https://i.imgur.com/Niob5by.png)

设置报警动作 

![](https://i.imgur.com/ioxSige.png)

![](https://i.imgur.com/9cQPSTk.png)

报警消息设置如下：

    hostname: ({HOST.NAME}
    Time:{EVENT.DATE} {EVENT.TIME}
    level:{TRIGGER.SEVERITY}
    message:{TRIGGER.NAME}
    event:{ITEM.NAME}:{ITEM.VALUE}
    url:www.abcdocker.com

恢复报警如下：

    hostname: ({HOST.NAME}
    Time:{EVENT.DATE} {EVENT.TIME}
    level:{TRIGGER.SEVERITY}
    message:{TRIGGER.NAME}
    event:{ITEM.NAME}:{ITEM.VALUE}
    url:www.abcdocker.com

报警配置如下 

![](https://i.imgur.com/U7kcKkT.png)

恢复配置如下 

![](https://i.imgur.com/uj6ve3L.png)

提示： 不要忘记先点小的`add-->小的update-->Update`

## 六、测试
为了验证效果我们停掉zabbix-agent,进行查看报警

    [root@abcdocker ~]# systemctl stop zabbix-agent

报警如下 

![](https://i.imgur.com/5YsnPxl.png)

![](https://i.imgur.com/JCmhU83.jpg)

本文参考：
 
[Zabbix-3.0.3实现微信（WeChat）告警](https://www.abcdocker.com/wp-content/themes/begin/inc/go.php?url=http://www.linuxprobe.com/zabbix-alert-with-wechat.html)

转自：[Zabbix-3.2.3实现微信（WeChat）告警](https://www.abcdocker.com/abcdocker/2472)