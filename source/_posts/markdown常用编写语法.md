---
title: Markdown文件的常用编写语法
date: 2015-01-19 00:34:14
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "技术工具" #分类 
tags: #标签 
  - Markdown
---

![](https://i.imgur.com/tGwzRBZ.jpg)

<!--more-->
## 序言:
很久没有写博客了，感觉只要是不写博客，人就很变得很懒，学的知识点感觉还是记不住，渐渐地让我明白，看的越多，懂的越少（你这话不是有毛病吗？应该是看的越多，懂的越多才对），此话怎讲，当你在茫茫的前端知识库里面东看看，西看看的时候，很快就被海量的知识给淹没了，根本就不知道哪些是对的，哪些是错的，感觉好像这个也懂了，那个也懂了，但是真正写起来，脑子又一片空白，又好像什么都不懂，这种状态时有发生，这就叫不懂装懂，最根本的原因就是看的太多，写的太少，所以为了改掉这样毛病，把被动学习变成主动学习，接下来的日子，多写写，即使是写一些学习工作中遇到的坑也是好的，没事翻出来看看，还可以加深印象，好了，废话到处！


## 起因：

因为现在的前端基本上都用上了前端构建工具，那就难免要写一些readme等等的说明性文件，但是这样的文件一般都是.md的文件，编写的语法自然跟其他格式的文件有所区别，置于为什么要用这种格式的文件，不要问我，我也不知道，大家都这么用，跟着用就对了，如果有大神知道的，不妨告知小弟，本文也是我学习写markdown文件的一个笔记吧，仅供参考！

## 正文：

### 1、标题的几种写法：


第一种：

![](https://i.imgur.com/i6m1ota.png) ![](https://i.imgur.com/hxbMb7f.png)
   

前面带#号，后面带文字，分别表示h1-h6,上图可以看出，只到h6，而且h1下面会有一条横线，注意，#号后面有空格

第二种：

![](https://i.imgur.com/sDXaItc.png) ![](https://i.imgur.com/bSN9zOZ.png)
    

这种方式好像只能表示一级和二级标题，而且=和-的数量没有限制，只要大于一个就行

第三种：

![](https://i.imgur.com/7yd7uS6.png) ![](https://i.imgur.com/l6JXpRP.png)
   

这里的标题支持h1-h6，为了减少篇幅，我就偷个懒，只写前面二个，这个比较好理解，相当于标签闭合，注意，标题与#号要有空格

那既然3种都可以使用，可不可以混合使用呢？我试了一下，是可以的，但是为了让页面标签的统一性，不建议混合使用，推荐使用第一种，比较简洁，全面

为了搞清楚原理，我特意在网上搜一下在线编写markdown的工具，发现实际上是把这些标签最后转化为html标签，如图：
![](https://i.imgur.com/g5y2SHc.png)


在线地址请看这里： [http://tool.oschina.net/markdown/](http://tool.oschina.net/markdown/) （只是想看看背后的转换原理，没有广告之嫌）

### 2、列表

我们都知道，列表分为有序列表和无序列表，下面直接展示2种列表的写法：

![](https://i.imgur.com/FVuhdbH.png) ![](https://i.imgur.com/X7jAPHI.png)  

可以看到，无序列表可以用* ， + ， — 来创建，用在线编辑器看，实际上是转换成了ul>li ，所以使用哪个都可以，推荐使用*吧

![](https://i.imgur.com/o6iSI8W.png) ![](https://i.imgur.com/Xzc3EWX.png)    

有序列表就相对简单一点，只有这一种方式，注意，数字后面的点只能是英文的点，特别注意，有序列表的序号是根据第一行列表的数字顺序来的，比如说：

![](https://i.imgur.com/IePiMk9.png) ![](https://i.imgur.com/KEhZFWM.png) ![](https://i.imgur.com/5Ej3T7n.png) ![](https://i.imgur.com/qVv7th5.png)    

第一组本来是3 2 1 倒序，但是现实3 4 5 ，后面一组 序号是乱的， 但是还是显示 3 4 5 ，这点必须注意了

### 3、区块引用

比如说，你想对某个部分做的内容做一些说明或者引用某某的话等，可以用这个语句

![](https://i.imgur.com/cAc0iof.png) ![](https://i.imgur.com/ENKlD9X.png) 

无序列表下方的便是引用，可以有多种用途，看你的需求了，用法就是在语句前面加一个 > ，注意是英文的那个右尖括号，注意空格

引用因为是一个区块，理论上是应该什么内容都可以放，比如说：标题，列表，引用等等，看看下图：

![](https://i.imgur.com/ND22BCQ.png) ![](https://i.imgur.com/kdtwGVq.png)  

将上面的代码稍微改一下，全部加上引用标签，就变成了一个大的引用，还有引用里面还有引用，那引用嵌套引用还没有别的写法呢？

![](https://i.imgur.com/lgvq6z3.png) ![](https://i.imgur.com/8sUnrfA.png)   

上图可以看出，想要在上一次引用中嵌套一层引用，只需多加一个>，理论上可以无限嵌套，我就不整那么多了，注意：多层嵌套的>是不需要连续在一起的，只要在一行就可以了，中间允许有空格，但是为了好看，还是把排版搞好吧


### 4、华丽的分割线

分割线可以由* - _（星号，减号，底线）这3个符号的至少3个符号表示，注意至少要3个，且不需要连续，有空格也可以

![](https://i.imgur.com/TmoQcq2.png) ![](https://i.imgur.com/A4KagmX.png)  

应该看得懂吧，但是为了代码的排版好看，你们自己定规则吧，前面有用到星号，建议用减号

 

### 5、链接

支持2种链接方式：行内式和参数式，不管是哪一种，链接文字都是用 [方括号] 来标记。

![](https://i.imgur.com/sqmDz5m.png) ![](https://i.imgur.com/3F5RXGX.png)   

上图可知，行内式的链接格式是：链接的文字放在[]中，链接地址放在随后的（）中，举一反三，经常出现的列表链接就应该这样写：

![](https://i.imgur.com/jxqUrr7.png) ![](https://i.imgur.com/R83SJ4n.png) 

链接还可以带title属性，好像也只能带title，带不了其他属性，注意，是链接地址后面空一格，然后用引号引起来

![](https://i.imgur.com/xoWmmSB.png)

这是行内式的写法，参数式的怎么写：

![](https://i.imgur.com/8g5Xfgp.png) ![](https://i.imgur.com/4XzHfkv.png)   

这就好理解了，就是把链接当成参数，适合多出使用相同链接的场景，注意参数的对应关系，参数定义时，这3种写法都可以：

[foo]: http://example.com/ "Optional Title Here"

[foo]: http://example.com/ 'Optional Title Here'

[foo]: http://example.com/ (Optional Title Here)

还支持这种写法，如果你不想混淆的话：

[foo]: <http://example.com/> "Optional Title Here"

其实还有一种隐式链接的写法，但是我觉得那种写法不直观，所以就不写了，经常用的一般就上面2种，如果你想了解隐式链接，可以看我文章最后放出的参考地址

 

### 6、图片

图片也有2种方式：行内式和参数式，

![](https://i.imgur.com/GGjaxHb.png) ![](https://i.imgur.com/oWcmpEr.png)  

用法跟链接的基本一样，唯一的不同就是，图片前面要写一个！（这是必须的），没什么好说的

 

### 7、代码框

这个就比较重要了，很多时候都需要展示出一些代码

如果代码量比较少，只有单行的话，可以用单反引号包起来，如下：

![](https://i.imgur.com/acntC6g.png) ![](https://i.imgur.com/H83ajQK.png)  

要是多行这个就不行了，多行可以用这个：

![](https://i.imgur.com/YwmRk1S.png) ![](https://i.imgur.com/doxdKK7.png)   

多行用三个反引号，如果要写注释，可以在反引号后面写

### 8、表格

这个写的有点麻烦，注意看

![](https://i.imgur.com/WrLHDWO.png) ![](https://i.imgur.com/mcehYcN.png)   

从这3种不同写法看，表格的格式不一定要对的非常起，但是为了好看，对齐肯定是最好的，第一种的分割线后面的冒号表示对齐方式，写在左边表示左对齐，右边为右对齐，两边都写表示居中，还是有点意思的，不过现实出来的结果是，表格外面并没有线框包起来，不知道别人的怎么弄的

 

### 9、强调

![](https://i.imgur.com/mkBlaE9.png) ![](https://i.imgur.com/5fnekTA.png)    

一个星号或者是一个下划线包起来，会转换为<em>倾斜，如果是2个，会转换为<strong>加粗

### 10、转义

![](https://i.imgur.com/4q2T75e.png) ![](https://i.imgur.com/9kznDpJ.png)     

就不一一列举了，基本上跟js转义是一样的

### 11、删除线

![](https://i.imgur.com/2wSLqJY.png) ![](https://i.imgur.com/Kb1mAam.png)  

 

常用的基本上就这些了，如果还有一些常用的，可以跟我留言，我补充上去，我觉得图文并茂才是高效学习的正确姿势，但愿为你的学习带来帮助！

<font size="4">*以上整理主要参照下面的文档，如涉及侵权请联系本人，进行删除。*</font><br /> 

参考文献：

[Markdown 语法说明 (简体中文版)](http://www.appinn.com/markdown/)

[认识与入门 Markdown](http://sspai.com/25137)


 