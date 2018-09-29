---
title: Hexo NexT主题内接入网页在线联系功能
date: 2015-02-26 11:34:14
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "Hexo" #分类 
tags: #标签 
  - Hexo
---

![](https://i.imgur.com/x59Nq3J.jpg)

<!--more-->
之前有访问过一些大佬的个人博客，里面有个在线联系功能，看着不错，所以也试着在自己的站点上接入了此功能。

## 注册
首先在[DaoVoice](http://www.daovoice.io/)注册个账号，点击->[邀请码](http://dashboard.daovoice.io/get-started?invite_code=0f81ff2f)是`2e5d695d`。

![](https://i.imgur.com/M8OW5wK.png)


完成后，会得到一个`app_id`，后面会用到：

![](https://i.imgur.com/itKGZZ9.png)

## 修改head.swig
修改`/themes/next/layout/_partials/head.swig`文件，添加内容如下：

    {% if theme.daovoice %}
      <script>
      (function(i,s,o,g,r,a,m){i["DaoVoiceObject"]=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;a.charset="utf-8";m.parentNode.insertBefore(a,m)})(window,document,"script",('https:' == document.location.protocol ? 'https:' : 'http:') + "//widget.daovoice.io/widget/0f81ff2f.js","daovoice")
      daovoice('init', {
      app_id: "{{theme.daovoice_app_id}}"
    });
      daovoice('update');
      </script>
    {% endif %}
位置贴图：

![](https://i.imgur.com/SwgFg26.png)

## 主题配置文件
在`_config.yml`文件中添加内容：

    # Online contact
    daovoice: true
    daovoice_app_id:   # 这里填你刚才获得的 app_id
## 聊天窗口配置
附上我的聊天窗口的颜色、位置等设置信息：

![](https://i.imgur.com/YFQKjny.png)

至此，网页的在线联系功能已经完成，重新`hexo g`，`hexo d`上传GitHub后，页面上就能看到效果了。

就比如说你现在往右下角看看(～￣▽￣)～ ，欢迎撩我（滑稽）。