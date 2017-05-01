---
title: Blogging with Hexo and Next Theme
date: 2017-05-01 07:22:23
categories:
- blogs
tags:
- nodejs
- hexo
---

## Hexo

嗨，**[Hexo]** 是一套快速、簡單且強大的網誌框架，支援 [Markdown]，以及還有許多的**外掛套件**和**佈景主題**。

所以決定改用這套來新寫一個 **Blog** ，這樣可以把文章做版本控制，也因為可以使用 **Markdown**，所以只要給個[文字編輯器]，就可以寫了。
更讚的是 **Android** 的 [Termux] 也因為有 [Node.js] 的套件，所以其實完全是可以帶個手機平板，就可以隨時更新以及發佈內容的。

> - *Termux* 實在太讚，所以要講很多次 XD
> - 雖然對 [rst] 比較有愛，但真的 [md] 比較紅一點啦 XDDD

而這篇就主要寫一下，用到的佈景主題以及相關的設定。

## Next

**[Next]** 是目前正在使用的 **[Hexo]** 佈景主題，拖到最下面也有寫啦以茲證明，哈哈哈。
**[Next]** 也還有分不同的外觀配置，目前選用 **Pisces**。

### Next and _config

不過通常安裝一個 [Hexo] 的佈景主題的步驟通常是這樣的：

```sh
$ cd your-hexo-site
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```

然後會需要更改裡面的配置文件 `_config.yaml`，這時候問題就來了，畢竟 `_config.yaml` 是放在佈景主題的 **git repo** 裡的，
變更了想儲存一下總不能 `push` 回去吧。

> 所以就決定把配置文件放在外面，每次再複製過去佈景主題的目錄裡面就好了。
> 反正還不太需要大改佈景主題裡面的東西。

因此也把這些步驟寫成一個 **Makefile**，也把相依關係也寫在裡面。

```sh
theme:
	@ [ -f themes/next_config.yml ] && cp themes/next_config.yml ./themes/next/_config.yml

generate: theme
	@ hexo g

service: generate
	@ hexo s
```

### Next and custom

不過的確很多選項並沒有都放在 `_config.yaml` 裡面，像是某些 **CSS** 相關的設定。
當然也都可以如法泡製 `_config.yaml` 的方法，但每個 **stylus** 檔案都要改上一點的話，那還真的需要 `fork` 一個佈景主題才行。

後來發覺 [Next] 本來就有考慮到這層需求，所以像是自訂**CSS**的部份，已經有個叫作 `_custom/custom.styl` 空檔案了，

> 其實可以把需要覆蓋的 css style 語法貼過去 `custom.styl` 就可以了。


## Mermaid

[Mermaid] 是一個可以用文字檔畫個關係圖流程圖的生成工具。（覺得也有點像是 DOT graphviz ）

也有人寫了 [Hexo] 的外掛，可以在 **Blog** 的檔案中使用 [Mermaid] 語法產生流程圖。

先安裝一下：
```sh
$ npm install hexo-tag-mermaid --save
```

接著要讓佈景主題也加上 [Mermaid] 的 **javascript** 和 **css** 檔案，`themes/next/layout/_partials/head/custom-head.swig`。

```html
<!-- mermaid -->
<script type="text/javascript" src="https://cdn.bootcss.com/mermaid/6.0.0/mermaid.min.js" charset="utf-8"></script>
<link href="https://cdn.bootcss.com/mermaid/6.0.0/mermaid.min.css" rel="stylesheet" type="text/css" />
```

然後就可以試試看了：

```mermaid
{% mermaid %}
sequenceDiagram
    participant Alice
    participant Bob
    Alice->John: Hello John, how are you?
    loop Healthcheck
        John->John: Fight against hypochondria
    end
    Note right of John: Rational thoughts <br/>prevail...
    John-->Alice: Great!
    John->Bob: How about you?
    Bob-->John: Jolly good!
{% endmermaid %}
```

{% mermaid %}
sequenceDiagram
    participant Alice
    participant Bob
    Alice->John: Hello John, how are you?
    loop Healthcheck
        John->John: Fight against hypochondria
    end
    Note right of John: Rational thoughts <br/>prevail...
    John-->Alice: Great!
    John->Bob: How about you?
    Bob-->John: Jolly good!
{% endmermaid %}


[Hexo]: https://hexo.io/zh-tw/
[Markdown]: https://zh.wikipedia.org/wiki/Markdown
[文字編輯器]: http://www.vim.org/
[md]: https://zh.wikipedia.org/wiki/Markdown
[Termux]: https://termux.com/
[Node.js]: https://nodejs.org/en/
[rst]: http://docutils.sourceforge.net/rst.html
[Next]: http://theme-next.iissnan.com/
