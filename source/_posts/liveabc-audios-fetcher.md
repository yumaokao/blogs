---
title: LiveABC Audios Fetcher
date: 2017-05-03 12:42:01
categories:
- environment
tags:
- python
- commandline
---

## Live ABC 互動英語

[LiveABC] 互動英語出了好多英語學習雜誌，像是 CNN 互動英語、Biz 互動英語等等，應該是最多量的一家了吧。買雜誌的話，通常會分有附互動光碟版以及課文朗讀版，不管哪一種都是有附 CD 光碟的。

{% cq %}
**現在沒人在用光碟了啦！!**
{% endcq %}
<!-- more -->

其實也是真的只有雜誌版，那要聽裡面原文發音的人等等怎麼辦呢？~~收聽廣播~~ 其實通常都會放在網路上讓人下載啦，只是會需要登入會員才行。

### Biz

{% cq %}
**但其實知道網址的話，下載是不需要登入的。**
{% endcq %}

所以只要知道下載網址的規則就好了XD。

以 Biz 互動英語2017年4月份為例，音檔是被包成三個 `zip` 檔案這樣放的。

```sh
$ wget http://www.liveabc.com/declaim/biz/10604/Normal/biz10604n_01_13.zip
$ wget http://www.liveabc.com/declaim/biz/10604/Normal/biz10604n_14_26.zip
$ wget http://www.liveabc.com/declaim/biz/10604/Normal/biz10604n_27_30.zip
```

規則看起來就是：
1. **`biz`** 就是 Biz 互動英語
1. **`10604`** 就是民國壹零陸年的肆月份
1. **`01_13.zip`** 就是包含了01到13個音檔

上面最有趣的部份就是 **`01_13.zip`** 這個了，因為每次數字其實不太一定，但又不想要登入去拿到明確的下載網址，該怎麼辦呢？

那就都試試看就好了，反正一個月只需要掃一次而已！
而且已知 **`aa_bb.zip`**，**`bb`** 一定大於 **`aa`**，就寫了一個自己抓出下載網址工具了。


```python
def biz(year=105, month=9):
    if month == 0:
        year -= 1
        month = 12
    begin = 1
    end = begin

    hostname = 'http://www.liveabc.com'
    while True:
        url = '{h}/declaim/biz/{y}{m:02}/Normal/biz{y}{m:02}n_{b:02}_{e:02}.zip'.format(h=hostname, y=year, m=month, b=begin, e=end)
        r = requests.get(url)
        if r.status_code == 200:
            yield url
            begin = end + 1
        end = end + 1
        if end > 36:
            break
```

## Ivy League 常春藤英語

[常春藤] 英語也是出了好幾本英文雜誌，像是解析英語覺得實在很讚。

前面說了，通常音檔都會放在網路上讓人下載，只是需要登入。

### Ivy Analytical English

{% cq %}
**但其實知道網址的話，下載是不需要登入的。**
{% endcq %}

不過以上這句，依然適用喔。

底下是2017年5月12日的音檔網址：

```sh
http://broadcast.ivy.com.tw/broadcast/BoardData/Ivy/mp3/6351_2.mp3
```

規則是：
1. **`6351`** 就是音檔的流水號，數字會遞增，**但不一定只差1喔**
1. **`6351_2`** 就是_2的有包含解說的音檔

那麼要怎麼知道雜誌上今天對應的音檔呢？
[常春藤] 通常周一到周六都會有音檔，而且是漸增的，所以可以把數字做排序的 list，接著只要知道一個定位點，再根據跟這個定位點的集數 offset 回去找 list 中的數字就可以了。

大概是像這樣：
```python
    today = date.today() 
 
    # anchor: please select a Monday as an anchor 
    anchor = date(2014, 12, 1) 
    origin = 4805 
    delta = today - anchor 
    offset = delta.days - (delta.days // 7) 
    for a in sys.argv: 
        try: 
            offset += int(a) 
        except: 
            pass 
 
    hostname = 'http://broadcast.ivy.com.tw' 
    r = requests.get(hostname + '/broadcast/BoardData/Ivy/mp3/') 
 
    root = parse(StringIO(r.text)).getroot() 
    mp3s = filter(lambda t: match(".*_2.mp3", t.get('href')), root.findall(".//a[@href]")) 
    mp3s = list(map(lambda t: (int(t.text[:-2]), hostname + t.get('href')), mp3s)) 
    mp3s = filter(lambda m: m[0] > origin - 1, mp3s) 
    mp3s = sorted(mp3s, key=lambda m: m[0]) 

    if len(mp3s) < offset + 1: 
        sys.exit("not found in the page") 
    else: 
        print(mp3s[offset][1]) 

```

[LiveABC]: http://www.liveabc.com/index.asp
[常春藤]: https://www.ivy.com.tw/

<!--- {% gist fa5ee6d043cf0965d22e3ed444fdcf80 %} -->
