---
title: Hexo NexT主题内加入动态背景
date: 2015-02-25 00:34:14
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "Hexo" #分类 
tags: #标签 
  - Hexo
---

![](https://i.imgur.com/U9BvluU.jpg)

<!--more-->
主题内新添加内容

<font size="5">**_layout.swig**</font><br /> 

找到`themes\next\layout\_layout.swig`文件，添加内容：
在`<body>`里添加：

    <div class="bg_content">
      <canvas id="canvas"></canvas>
    </div>



仍是该文件，在末尾添加：

    <script type="text/javascript" src="/js/src/dynamic_bg.js"></script>

<font size="5">**dynamic_bg.js**</font><br /> 

在`themes\next\source\js\src`中新建文件`dynamic_bg.js`，代码链接中可见：[dynamic_bg.js](https://github.com/asdfv1929/asdfv1929.github.io/blob/master/js/src/dynamic_bg.js)

<font size="5">**custom.styl**</font><br /> 
在`themes\next\source\css\_custom\custom.styl`文件末尾添加内容：

    .bg_content {
      position: fixed;
      top: 0;
      z-index: -1;
      width: 100%;
      height: 100%;
    }
    
<font size="5">*以上整理主要参照下面的文档，如涉及侵权请联系本人，进行删除。*</font><br /> 

**参考：**

[Hexo NexT主题内加入动态背景](https://asdfv1929.github.io/2018/07/07/next-add-dynamicbg/)