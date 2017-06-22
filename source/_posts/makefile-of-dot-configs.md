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

就我個人來說，會想要紀錄一下自己設定檔的變動狀況，以避免改到爛掉，另外也就可以產生出 **`.vimrc`** 的演進史之類的XD
{% blockquote %}
所以會把 **Dot Config Files** 放到個人的 **git repo** 中做版本管理
{% endblockquote %}

如果有好幾台電腦的話，這麼做也很容易的在不同電腦間，同步更新這些設定檔了，相當方便，除了每次都要**手動複製設定檔到家目錄去**之外XDDDD

{% cq %}
所以寫了一個 **Makefile** 自動更新以及備份家目錄的設定檔
{% endcq %}

<!-- more -->
# Makefile of Dot Config Files
這個 **Makefile** 所在的目錄架構大概是這樣的，同層會有對應的設定檔目錄：
{% codeblock %}
$ ls -l
drwxr-xr-x 2 yumaokao yumaokao 4096  5月 23 10:51 bash
drwxr-xr-x 2 yumaokao yumaokao 4096  3月 13 09:43 bin
drwxr-xr-x 2 yumaokao yumaokao 4096  5月 19 14:23 docker
drwxr-xr-x 2 yumaokao yumaokao 4096  5月 22 15:38 i3
-rw-r--r-- 1 yumaokao yumaokao 5313  5月 23 10:32 Makefile
drwxr-xr-x 2 yumaokao yumaokao 4096  9月 13  2016 mutt
drwxr-xr-x 4 yumaokao yumaokao 4096  5月 17 10:19 vim
drwxr-xr-x 2 yumaokao yumaokao 4096  2月 13 10:22 zsh

$ ls -l bash
-rw-r--r-- 1 yumaokao yumaokao  264  1月  4  2016 bash_aliases
-rw-r--r-- 1 yumaokao yumaokao  591  6月 12  2015 bash_profile
-rw-r--r-- 1 yumaokao yumaokao  591  9月 13  2016 bash_profile.ahostname
-rw-r--r-- 1 yumaokao yumaokao 3353  6月 12  2015 bashrc
-rw-r--r-- 1 yumaokao yumaokao  703  6月 12  2015 profile

{% endcodeblock %}

只要設定檔的規則寫在 **Makefile** 裡，然後就可以直接打如 **`make bash`** 這樣的命令，便會依造規則把上面放在 **bash/** 裡面新的設定更新到家目錄去。

然後就發現好多規則很像，每次都複製貼上有點蠢XD
{% blockquote %}
所以這個 **Makefile** 有寫了幾個 **function** 可以呼叫。
{% endblockquote %}

## Useful Functions
```makefile
BACKUP_CONFIGS := ~/.backup_configs/
HOSTNAME := $(shell hostname)

define mkdir_config
        @ echo checking dirctory: $1
        @ [ -d $1 ] || mkdir -p $1
endef

define backup_config
        @ echo backup_config: $1, $2
        $(call mkdir_config, ~/.backup_configs)
        @ if [ -f $1 ]; then diff $1 $2 > /dev/null 2>&1 || cp --parents $1 $(BACKUP_CONFIGS); fi
endef

define update_config
        @ echo update_config: $1 from $2
        $(if $(wildcard $2.$(HOSTNAME)), $(call _update_config, $1, $2.$(HOSTNAME)), $(call _update_config, $1, $2))
endef

define _update_config
        @ echo _update_config: $1 from $2
        $(call backup_config, $1, $2)
        @ if [ -f $2 ]; then diff $1 $2 > /dev/null 2>&1 || cp $2 $1; fi
endef
```

所以要怎麼利用這些共用的 **functions** 呢？用上面的 **`make bash`** 為例
```makefile
bash:
        $(call update_config, ~/.$@rc, $@/$@rc)
        $(call update_config, ~/.$@_aliases, $@/$@_aliases)
        $(call update_config, ~/.profile, $@/profile)
        $(call update_config, ~/.$@_profile, $@/$@_profile)
```

稍微解說一下 **`update_config`** 會發生什麼事，像是 **bash** 這邊的第一條規則，意思就是說想要把跟 **Makefile** 同一層目錄的 **bash/bashrc** 更新到家目錄的 **.bashrc**。
1. **`mkdir_config`** 檢查一些目錄是不是已經有建立了，如果沒有才利用 **`mkdir -p`** 來新建目錄。
1. **`update_config`** 接著會檢查是不是有存在 **bash/bashrc.HOSTNAME** 的檔案，如果有發現就使用這個，沒有的話則使用預設的 **bashrc** 檔案，然後繼續下面步驟。
1. **`backup_config`** 會先檢查要新舊設定檔是不是有異動，有的話才會將舊的設定檔連同目錄架構給放到備份的目錄去。
1. **`_update_config`** 也會先檢查新舊設定檔異同，有不一樣才會把新的設定檔蓋過舊的，完成真正的更新。

## Vim
大部份的程式，都是設定檔更新後，再重開程式就會生效了，這邊要另外講的是 **[Vim]** 這個文字編輯器。
像我個人是使用 **[Vundle]** 來管理 **[Vim]** 的 **plugins** ，可能每次更新 **.vimrc** 之後，會有一些 **plugins** 的變動，通常會需要再執行一次 **[Vundle]** 的更新指令，所以也順便寫在 **Makefile** 裡了，大致長得像這樣

```makefile
vim: flake8
        $(call update_config, ~/.$@rc, $@/$@rc)
        ## for vundle
        @ [ -d ~/.vim/bundle/vundle ] || git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
        @ vim +BundleInstall! +qall
```


[Linux]: https://www.kernel.org/
[Vim]: http://www.vim.org/
[Vundle]: https://github.com/VundleVim/Vundle.vim
