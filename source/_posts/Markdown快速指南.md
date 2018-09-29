---
title: Hello World
date: 2015-01-19 00:34:14
comments: true #是否可评论 
toc: true #是否显示文章目录
categories: "云服务器" #分类 
tags: #标签 
  - 语法笔记
---

<!--more-->

<font size="5">*以上整理主要参照下面的文档，如涉及侵权请联系本人，进行删除。*</font><br /> 


# 标题 1
## 标题 2
### 标题 3
#### 标题 4
##### 标题 5
###### 标题 6


**Bold 加粗**

*Emphasize 强调*

++Underline 下划线++

~~Strikethrough 删除线~~

==Highlight 高亮==

上标^Superscript上标^

下标~Subscript下标~

** 插入图片 **

![alt text](http://www.kankanews.com/ICkengine/wp-content/plugins/wp-o-matic/cache/69430231b7_140905163467611.jpg)

** 超链接 **

[link text Markdown 语法说明](http://www.appinn.com/markdown/)

*引用*
> 一级引用
> To follow the path, look to the master, follow the master, walk with the master, see through the master, become the master.

>> 二级引用
>> 我比较认同《教父》里的人生观，第一步要努力实现自我价值，第二步要全力照顾好家人，第三步要尽力帮助善良的人，第四步为族群发声，第五步为国家争荣誉。而那些随意颠倒次序的人，一般不值得信任。

- Unordered List
- 无序列表

1. Order List
2. 有序列表

- [ ] Task list
- [x] 任务列表

插入脚注[^1]

[^1]:脚注引用

== 插入代码块 ==
- 方法一：
>使用tab键

		public class Markdown{
		public static void main(string args[]){
				System.out.println( "Hello MarkDown! \n" );
			}
		}

- 方法二：
>使用 \``` code ```

```
public class Markdown{
   public static void main(string args[]){
       System.out.println( "Hello MarkDown! \n" );
   }
}

```

== 插入行内代码 ==
此处演示在行内插入代码 使用Python创建简单的HTTP服务器: `python -m SimpleHTTPServer 8888`

####表格

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

####page break 分页符
***

####Section break 分节符
下面是分节符

- - -

上面是分节符

####Sentence break 分段符
下面是分段符
_ _ _

上面是分段符
