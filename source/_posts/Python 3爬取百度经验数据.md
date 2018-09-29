---
title: Python 3爬取百度经验数据
date: 2018-5-24 09:15:12
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "Python" #分类 
tags: #标签 
  - Python
---

![](https://i.imgur.com/33HIm4H.jpg)

<!--more-->
## 安装环境准备

直接使用win10的wsl沙盒Ubuntu系统，自带python3.5

安装

    apt install python3-pip
    pip3 install rsa


### 注意事项

`IndentationError: unexpected indent` 检查缩进是否一致，空格和Tab符号注意区分
##实战
### 通过cookie爬百度数据

1.登陆百度，通过浏览器设置-内容管理-cookie，找到百度的BDUSS的内容复制


![](https://i.imgur.com/wFw6BaW.gif)


2.编写脚本login.py

    import requests
    #需要爬数据的url
    url = 'http://i.baidu.com/'
    #浏览器访问网站的cookie信息
    cookie = {"BDUSS":"----------------------------------------------------AAAAAAAAAAA----------------AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA--"}
    #requests请求，获取登录网站页面的内容
    html = requests.get(url,cookies=cookie).content
    #print(html)
    #把内容保存为文件
    with open("baidu.html", 'wb') as f:
    	f.write(html)
    	f.close()

3.在Ubuntu bash执行python3 login.py，会生成一个文件baidu.html在当前目录,打开如果能看到个人信息就证明获取成功

### 爬百度翻页数据

上面已经登陆成功了，下面直接用cookie进行爬数据会被重定向，还需要添加请求头，以及翻页参数


![](https://i.imgur.com/Lb8XaqU.gif)


    import requests
    #需要爬数据的url
    url = 'https://jingyan.baidu.com/user/nucpage/content'
    #浏览器访问网站的cookie信息
    cookie = {"BDUSS":"-----QAAAAAAAAAAAEAAA--1QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA---"}
    
    #提供你所使用的浏览器类型、操作系统及版本、CPU 类型、浏览器渲染引擎、浏览器语言、浏览器插件等信息的标识
    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
    # 从那个连接来的
    referer="https://jingyan.baidu.com/user/nucpage/content"
    # 设置请求头
    headers = {
    "User-Agent": user_agent,
    "Referer": referer
    }
    # url参数
    # https://jingyan.baidu.com/user/nucpage/content?tab=exp&expType=published&pn=20
    params = {
    'tab': 'exp',
    'expType': 'published',
    'pn': '30'
    }
    
    #requests请求，获取登录网站页面的内容
    html = requests.get(url,cookies=cookie,headers=headers).content
    
    #print(html)
    #把内容保存为文件
    with open("baidu.html", 'wb') as f:
    	f.write(html)
    	f.close()

### 最终版爬百度经验的个人经验数据

    import requests
    #正则
    import re
    #需要爬数据的url
    url = 'https://jingyan.baidu.com/user/nucpage/content'
    #浏览器访问网站的cookie信息
    cookie = {"BDUSS":"--AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-"}
    
    #提供你所使用的浏览器类型、操作系统及版本、CPU 类型、浏览器渲染引擎、浏览器语言、浏览器插件等信息的标识
    user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36"
    # 从那个连接来的
    referer="https://jingyan.baidu.com/user/nucpage/content"
    # 设置请求头
    headers = {
    "User-Agent": user_agent,
    "Referer": referer
    }
    
    
    #requests请求,获取发布数量
    published = requests.get(url,cookies=cookie,headers=headers).content
    #<li><a class="on" href="/user/nucpage/content">已发布 (505)</a></li>
    reg=r'<li><a class="on" href="/user/nucpage/content">已发布 \((.*?)\)</a></li>'
    publishedNum=re.search(reg,published.decode(),re.I|re.M|re.S).group(1)
    #group(0) 匹配的串，group(1) 匹配的串中第一个括号
    print(publishedNum)
    #算页数,实际篇数-1
    pages=int((int(publishedNum)-1)/20)+1
    print(pages)
    #把内容保存为文件,'w'是写，'wb'是写入byte
    with open("jingyan.md", 'w') as f:
    	for page in range(0,pages):
    		pn=page*20
    		print(pn)
    
    		# url参数
    		# https://jingyan.baidu.com/user/nucpage/content?tab=exp&expType=published&pn=20
    		params = {
    		'tab': 'exp',
    		'expType': 'published',
    		'pn': pn
    		}
    
    		#requests请求，获取登录网站页面的内容
    		html = requests.get(url,cookies=cookie,headers=headers,params=params).content
    
    		#过滤
    		reg=r'<a class="f14" target="_blank" title=(.*?)>'
    
    		#re.I 使匹配对大小写不敏感 
    		#re.M 多行匹配，影响 ^ 和 $ 
    		#re.S 使 . 匹配包括换行在内的所有字符 
    		#这个是查找此字符串中所有符合条件的内容并返回一个列表
    		list=re.findall(reg,html.decode(),re.I|re.M|re.S)
    		#写入文件并替换为markdown格式
    		for item in list:
    			item=item.replace('" href="','](https://jingyan.baidu.com')
    			item=item.replace('.html"','.html)')
    			item=item.replace('"','[')
    			f.write("%s\n" % item)
    f.close()

<font size="4">*以上整理主要参照下面的文档，如涉及侵权请联系本人，进行删除。*</font><br />

参考：

[Python：网页的抓取、过滤和保存](https://blog.csdn.net/u013632854/article/details/69662308)