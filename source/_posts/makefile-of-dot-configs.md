---
title: Makefile of Dot Config Files
date: 2017-05-22 15:44:23
categories:
- environment
tags:
- makefile
- shell
---

# Introduction
在 **Linux** 這樣的環境中，程式常常會有很多使用者可以調整的選項，這些選項會寫在一個或多個設定檔中，而這些設定檔通常都會放在**家目錄**底下，以 **`.`**為開頭，
{% blockquote %}
一般稱這種 User Configuration Files 叫 .(Dot) Files
{% endblockquote %}

對啦，就是那些得要用 **`ls -a`** 才能看得到的檔案以及目錄。如果要備份設定的話，只要把這些設定檔案給另外存起來，要復原的時候再放回去就好了，比較起來是相當簡易的方法。

就我個人來說，會想要紀錄一下自己設定檔的變動狀況，以避免改到爛掉，另外也就可以產生出 **`vimrc`** 的演進史之類的XD
{% blockquote %}
所以會把 **Dot Config Files** 放到個人的 **git repo** 中做版本管理
{% endblockquote %}

如果有好幾台電腦的話，這麼做也很容易的在不同電腦間，同步更新這些設定檔了，相當方便，除了每次都要**手動複製設定檔到家目錄去**之外XDDDD

{% cq %}
所以寫了一個 **Makefile** 自動更新以及備份家目錄的設定檔
{% endcq %}

<!-- more -->
# Makefile of Dot Config Files
## Useful Functions

[Linux]: https://termux.com/
