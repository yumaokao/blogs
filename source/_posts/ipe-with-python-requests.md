---
title: ipe, data fetch with python
date: 2017-04-26 13:25:41
categories:
- environment
tags:
- python
---

## ipe

[ipe] 是最近受到拜託寫的 Python 抓資料的程式，為了方便分享分心，也也就直接放到 GitHub 上了。

前後有分別是對兩個不同的網站抓大量的資料，所以是分成兩大部份，不過 code 還是放在一起啦XD。
不過只看原始碼可能還是會不太了解，某些值是怎麼得來的，以及過程中遇到的有趣的例外處理，就想要放在這篇趁我還記憶猶新寫起來。

個人喜好，所以全都是用 `Python3` ，用 [requests] 發要求，用 [lxml] 解析內容。覺得這些真是無敵好用模組啊！！

<!-- more -->

### ipe

### arsp


[ipe]: https://github.com/yumaokao/ipe
[requests]: http://docs.python-requests.org/en/master/
[lxml]: http://lxml.de/
