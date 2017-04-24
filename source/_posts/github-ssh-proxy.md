---
title: GitHub SSH and ProxyCommand
date: 2017-04-24 16:37:43
categories:
- environments
tags:
- ssh 
- proxy
- github
- tunneling
---

## GitHub and SSH

GitHub [建議使用] HTTPS URLs，因為使用 SSH 在授限制的環境中很有可能會被擋住。
> ** -- Which remote URL should I use?**
> The https:// clone URLs are available on all repositories, public and private.
> These URLs work everywhere--even if you are behind a firewall or proxy. 

通常在這種情況之下，我也都是使用 HTTPS，但還是會遇到幾種情況，預設是使用 SSH 去連 GitHub 的，有的可以改，有的不知道怎麼改，像是：
```sh
$ hub clone USERNAME/REPO
$ hexo deploy
```

不過因為已經有某條隧道，其實是可以 `ssh` 到外面某台主機的，所以其實可以指定每次連去 GitHub 的時候，都可以透過這台再轉連出去。

```
$ cat ~/.ssh/config
Host github.com
ForwardAgent yes
ProxyCommand ssh yumaokao@10.10.0.1 nc %h %p

```

這樣就可以直接使用 `hub clone yumaokao/blogs` 了，當然也就可以直接 `push` 回去。


[建議使用]: https://help.github.com/articles/which-remote-url-should-i-use/
