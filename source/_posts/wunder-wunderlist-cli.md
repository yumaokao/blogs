---
title: wunder-wunderlist-cli
date: 2017-04-25 16:59:32
categories:
- commandline
tags:
- commandline
- cli
- nodejs
- javascript
- GTD
---

## WunderList

[WunderList] 是最近幾年我常用的 [GTD] 工具，因為有出 Android 以及網頁版然後可以自動同步，就選來用了。
然後[它就被 Microfoft 買下來了](http://technews.tw/2015/06/03/microsoft-buys-german-to-do-list-startup-6wunderkinder/)，
再然後[它就要被停止服務，要換去新的 To-Do 了](https://techcrunch.com/2017/04/19/microsoft-to-shut-down-wunderlist-in-favor-of-its-new-app-to-do/)。

<!-- more -->
> ** -- Microsoft to shut down Wunderlist in favor of its new app, To-Do **
> Microsoft makes its forthcoming demise pretty clear.
> Stating its plans in black-and-white: **“we will retire Wunderlist,”**


## WunderList API and Google Keep

其實在使用 WunderList 之前，都是使用 Google [Keep]，當然也都有網頁以及 Android 支援，以及可以自動同步，但是 Google [Keep] 當時苦等 API 未果，而 [WunderList] 有出 API 可以自己寫程式連，就決定換過去了。

而為什麼想要有 API 呢？是因為常常都活在 CommandLine 底下，所以其實也都會希望可以直接有 CommandLine 程式可以管理這些代辦事項，想到就丟到 Inbox 等這種 [GTD] 管理，所以如果有 API 的話，就比較有機會有人幫忙寫了 CommandLine 的程式，就算沒有或是不合用，也可以自己寫一個。


## wunder

所以我就自己寫了一個程式 [wunder] ，可以直接連 [WunderList]，是用 [Node.js] 寫的，也有用 [Mocha] 寫單元測試，是個 [TDD] 來著，哈哈！

有人也寫過類似的程式啦，但覺得不太好用，而 [WunderList] 也有出 [Node.js] 的 Wrapper，但當時(2015)抓下來的時候，不知道為什麼不能動，所以就自己從 [WunderList RESTful API] 開始動手寫了一個。

基本功能可以用了，而因為每次都要發很多次 `HTTP GET` **令人覺得有點蠢**，所以我斷斷續續得加上 Cache 的功能。
啊但因為實在**太不認真**了，所以改得很慢，**慢到都要被停用了**，都還沒完整寫完，啊哈哈哈哈！

{% cq %}**所以我最近把它 [wunder 放到 GitHub 上](https://github.com/yumaokao/wunder)了，就有機會也當個參考一下。** {% endcq %}

無論如何，在寫 [wunder] 的過程中，實在學到不少，像是 javascript 的物件繼承，如何使用 [Mocha]，以及覺得最重要的就是 `Async` 的概念，以及 **[Promise]** 了，有機會一定要來好好講一下 (just made another promise XD)。


## Next

最後我決定要搬去 [Trello] 了，啊哈哈哈哈！

[WunderList]: (https://www.wunderlist.com/)
[GTD]: (https://en.wikipedia.org/wiki/Getting_Things_Done)
[Keep]: (https://keep.google.com/)
[wunder]: (https://github.com/yumaokao/wunder)
[Node.js]: (https://nodejs.org/en/)
[Mocha]: (https://mochajs.org/)
[TDD]: (https://en.wikipedia.org/wiki/Test-driven_development)
[WunderList RESTful API]: (https://developer.wunderlist.com/documentation)
[Promise]: (http://bluebirdjs.com/docs/getting-started.html)
