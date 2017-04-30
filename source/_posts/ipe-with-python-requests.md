---
title: ipe, data fetch with python
date: 2017-04-26 13:25:41
categories:
- environment
tags:
- python
---

## ipe

[ipe] 是最近受到拜託寫的 Python 抓資料的程式，為了方便分享，也就直接放到 GitHub 上了。

前後有分別對兩個不同的網站抓大量資料，所以分成兩大部份，不過 code 還是放在一起啦XD。
不過只看原始碼可能還是會不太了解，某些值是怎麼得來的，以及過程中遇到的有趣的例外處理，就想要放在這篇趁我還記憶猶新寫起來。

個人喜好緣故，所以全都是用 `Python3` ，用 [requests] 發要求，用 [lxml] 解析內容。
私心覺得這些真是無敵好用模組啊！！

<!-- more -->

### mermaid
{% mermaid %}
  graph TB
           subgraph one
           a1-->a2
           end
           subgraph two
           b1-->b2
           end
           subgraph three
           c1-->c2
           end
           c1-->a2
{% endmermaid %}

### arsp
先講 arsp 這個部份，因為這個網站不用登入，看來也沒有檢查 Cookie 的時效性，所以容易許多，也沒有太多例外狀況。

#### query url and parameters


### ipe

#### login and cookie

#### query url and parameters

#### result and decode_unicode

#### post error handling


[ipe]: https://github.com/yumaokao/ipe
[requests]: http://docs.python-requests.org/en/master/
[lxml]: http://lxml.de/
