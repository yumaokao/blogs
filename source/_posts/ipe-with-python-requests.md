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

前後有分別對兩個不同的網站抓大量資料，所以分成兩大部份 [arsp]/[ipe]，不過 code 還是放在一起啦XD。不過只看原始碼可能還是會不太了解，某些值是怎麼得來的，以及過程中遇到的有趣的例外處理，就想要放在這篇趁我還記憶猶新寫起來。

個人喜好緣故，所以全都是用 `Python3` ，用 [requests] 發要求，用 [lxml] 解析內容。真心覺得這些真是無敵好用模組，預設必裝！！

<!-- more -->
### arsp
先講 [arsp] 這個，因為這個網站不用登入，看來也沒有檢查 Cookie 的時效性，所以容易許多，也沒有太多例外狀況。就會以這篇來講如何抓到網址以及所帶的參數。

#### query url and parameters
通常像這種可以條件查詢的網頁，都會是利用 [HTML 表單]的方式寫好 **`submit`** 的 **`method`** 以及 **`action`** 等等，就可以送出表單裡面的內容做事情。以 [arsp] 為例的話，利用 Chrome 的檢查工具 [Chrome DevTools]，可以來查看到底點選了 **`查詢`** 了之後會發生什麼事。大概會看到就是呼叫到 **`doSearch()`**，然後再交由表單對某網址送 **POST** 方法。

{% blockquote %}
**太麻煩了，還得要看得懂 JavaScript 程式碼以及 HTML 語法，不太有效率。**
{% endblockquote %}

其實可以多多利用 [Chrome DevTools] 工具，像是 **Network** 這裡面的功能就可以紀錄到某段時間內網路溝通的細節。以這次的例子來看的話，就很容易擷取到都是對哪個網址發出 POST 和裡面帶資料，當然發出去的 Header、Cookie 等等訊息也是看得到的。

```
Request Headers:
    POST /NSCWebFront/modules/talentSearch/talentSearch.do?action=initSearchList&LANG=chi HTTP/1.1
    ...
    User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36
    Content-Type: application/x-www-form-urlencoded
    Cookie: JSESSIONID=5391552526A4693DC4924447C3E7F2DD; currentUserLocale=zh_TW; _ga=GA1.3.1332110389.1492040511; _gid=GA1.3.91147264.1493823683; _gat=1
    Request Headers:

Form Data:
    currentPage:
    pageSize:
    sortCondition:
    specCode:
    isSearch:1
    LANG:chi
    ...
```

#### main result
知道了都對哪個網址發怎樣的方法以及內容之後，就馬上可以使用 **`Python`** 的 [requests] 來試試看是不是可以成功抓到所需要的結果：

```python
COOKIE = 'JSESSIONID=9D08CD5044B57DB94723D285AF217184; currentUserLocale=zh_TW; _ga=GA1.3.124500067.1491977542'
headers = {'Origin': 'http://arsp.most.gov.tw',
	   'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.110 Safari/537.36',
	   'Content-Type': 'application/x-www-form-urlencoded',
	   ...
	   'Cookie': COOKIE}

payload = {'currentPage': '',
	   'pageSize': '100',
	   'sortCondition': '',
	   'specCode': '',
	   'isSearch': '1',
           ...}

r = requests.post(url_search, headers=headers, data=payload)
```

觀察所回傳的內容可以判斷其實是一個完整的 HTML，所以可以再利用 [lxml] 來找到所需要的資料，將它們整理起來。而只要知道總共有幾頁，就可以利用上面 **`payload`** 所帶的參數 **`currentPage`**，來自動收集全部的所有資料筆數了。

```python
text = urllib.parse.unquote(r.text)
m = re.search("共<em>(\d+)</em>筆資料│", text)
pages = int(int(m.group(1)) / 100)
```

#### detail result
雖然可以將所有筆數都收集到了，但是傳回來的只有基本的資料，需要更進一步去點選裡面所附的網址才能獲得更細節的資訊。再仔細觀察一下規則的話，會發現每筆資料的細節網址都很一致，只是所帶的參數 **`rsNo`** 有所不同而已。

{% blockquote %}
**只要獲得了每筆資料中的 rsNo 值，就可以獲得各種細節資料的內容**
{% endblockquote %}

細節內容的獲取方法跟上面是相當類似的，所以可以共用許多部份：

```python
def basic(self):
    self._base_get_table('initBasic', '基本資料', 1, 'c30Tblist')

def rsm02(self):
    self._base_get_table('initRsm02', '主要學歷', 5, 'c30Tblist2')

def rsm03(self):
    self._base_get_table('initRsm03', '相關經歷', 4, 'c30Tblist2')

def rsm05(self):
    self._base_get_table('initRsm05', '著作目錄', 5, 'c30Tblist2')

def get_detail(self):
    self.basic()
    self.rsm02()
    self.rsm03()
    self.rsm05()
    return self.detail
```

如此就可以抓到完整的細節資料，當然有些本來就不公開的，也就顯示為不公開了。最後將自動跑完所有筆數的資料再匯出成 **`csv`** 檔即可。


### ipe
[ipe] 也可以用跟 [arsp] 類似的方法，可以觀察到都是對某個網址發 **`POST`**，只是這次不一樣的地方是
1. 需要登入後的 Cookie 才有辦法成功的拿到資料
1. 成功回傳的資料不再是 HTML 了，而只是 JavaScript 的物件描述而已

所以還是可以自動抓取的，但是所用的 **Cookie** 值過一陣子之後會失效，需要再手動連一次獲得新的 **Cookie** 值。不過跑了一下發現每次大概都可以自動抓到幾萬筆，換算起來也只需要做個幾次就可以抓完全部接近十萬筆的資料，就決定這部份手動更新就可以了。抓完全部近十萬筆的資料，大概花了**六個小時**左右。

#### result
分析抓回來的內容，其實是把網頁的表格內容放在回傳的 **`content: "..."`** 這裡面。看起來很像 **JSON**，但其實不是，不過沒關係，反正只需要抓到雙引號裡面的字串內容就可以了。
```python
text = urllib.parse.unquote(r.text)
text = text.replace('\n', '').replace('\r', '')
m = re.search("content:'(.*)'", text)
```

#### decode_unicode
看起來內容可以成功解析了，但往往都有奇妙的例外產生。這邊回傳的內容用到了少見的 **`%uxxxx`** 格式，可以參考[這裡(非標準的實現)]。因為這個不是 **`W3C`** 標準，所以需要寫一個轉碼函式，不然看到的都會是亂碼。

**`python3`** 裡面最接近這種格式的解碼方法就是字串的 **`.decode('unicode-escape')`**了，可以將 **`b'\\uxxxx'`** 轉回 **`unicode 字串`**。

```python
In []: u'中文'.encode('unicode-escape')
Out[]: b'\\u4e2d\\u6587'

In []: type(u'中文'.encode('unicode-escape'))
Out[]: bytes

In []: b'\\u4e2d\\u6587'.decode('unicode-escape')
Out[]: '中文'
```

所以寫了一個轉換函式，將 **`%uxxxx`** 替換成 **`b\\uxxxx`**，再利用 **`eval()`** 做 **`.decode('unicode-escape')`**。
```python
def decode_u(a):
    if a is None:
        return ''
    b = "b'" + a.replace('%u', '\\u') + "'.decode('unicode-escape')"
    # print(b)
    try:
        s = eval(b)
    except:
        s = b
    return s
```

這樣就可以成功地顯示出來正確的 **`unicode 字串`**了。
```python
In []: decode_u('%u5E7F%u4E1C')
Out[]: '广东'
```

#### post error handling
好吧，往往都有奇妙的例外發生 **again**。會有抓回來的內容沒有辦法成功轉碼回來例子，有的是中間插了一個奇怪的字元，有的中間夾雜了空格。不過數量不是很多，所以還補了後處理程式，把這些例外的字串手動修正過後，再送去轉一次。最後收集起來就可以匯出成一份完整的 **csv** 檔案了。


[ipe]: https://github.com/yumaokao/ipe
[requests]: http://docs.python-requests.org/en/master/
[lxml]: http://lxml.de/
[arsp]: http://arsp.most.gov.tw/NSCWebFront/modules/talentSearch/talentSearch.do?action=initSearchList&LANG=chi
[HTML 表單]: https://www.w3schools.com/html/html_forms.asp
[Chrome DevTools]: https://developer.chrome.com/devtools
[這裡(非標準的實現)]: https://zh.wikipedia.org/wiki/%E7%99%BE%E5%88%86%E5%8F%B7%E7%BC%96%E7%A0%81
