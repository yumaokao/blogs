---
title: Multiple Hostnames in SSH Configs
date: 2017-05-22 15:44:23
categories:
- environment
tags:
- makefile
- shell
---

# Introduction
**[OpenSSH]** 是很好用的連線工具，因為太常用了，所以我都會使用 **.ssh/config** 設定檔，把很常用的 **host** 寫到裡面，而許多 **Shell** 的 **Tab Completion** 也會 parse 設定檔，所以可以少打很多很多的字。

但是會有一個問題，就是會因為所在的位置不同，想連線的 **host** 會有不同的 **hostname** 設定，舉例在家裡的話，會想要連線到 **NAS** 的 **Lan IP**，但在外面會應該要對應到 **NAS** 的 **VPN IP**。
<!-- more -->

[Linux]: https://termux.com/
