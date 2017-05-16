---
title: Termux and atexit in Android
date: 2017-05-16 11:29:38
categories:
- android
- termux
tags:
- android
- termux
- commandline
---

## termux-pacakges
**[之前]** 有提過 [Termux] 是個在 Android 底下的終端模擬器，而附上了 [Termux] 套件系統，可以用 **`apt`** 來管理安裝。
[termux-packages] 就是 [Termux] 編譯出這些套件的地方，裡面利用 [Docker] 來建構交叉編譯的環境。個別套件遇到的問題，就都會在 [termux-packages] 發 issues 討論。

## Issue #933
[Termux] 的作者 **[@fornwall]**，在2017/4/16發了一個 **[Issue #933]**，說在使用 **`libgpg-error`** 時遇到一些問題。

**[Issue #933]** 裡面附上的 Sample Code
```c
#define GPGRT_ENABLE_ES_MACROS
#include <gpg-error.h>
int main() { es_putc('A', es_stdout); }
```

用下列命令安裝執行
```c
apt install -y clang libgpg-error-dev && clang test.c -lgpg-error && ./a.out
```

理論上應該會要看到 **`A`** 顯示出來才對。但是只有在某些裝置才會顯示
  - **Working** (output produced): **aarch64** (tested on **Android 7.0 and 7.1** devices)
  - **Not working** (no output produced): 32-bit **arm** (tested on an **Android 6.0**)

<!-- more -->

### patches
因為這個問題，所以沒有辦法只好在用到 **`libgpg-error`** 的程式，其實就是 **`gnupg2`**，裡面加上了一些 **patches**。雖然可以暫時解掉，但還是希望能夠有正解的分析，才能安心地從 **`gnupg1`** 轉換到 **`gnupg2`**。

### aarch64 and arm
會對這個 Issue 引起興趣是因為 **[@fornwall]** 猜測是 **arch** 的不同引起的差異。
個人之前在 [Termux] 上遇到問題的時候，也是很容易就會猜測是 **arch** (e.g. x86_64) 不同造成的，有機會會另外寫一篇講這個，後來詳細追了下去，發覺其實都是 **Android** 本身系統問題，很難是 **arch** 造成的原因。


## atexit
很快地把 **Sample Code** 編譯起來在自己的幾台機器跑了一下，發覺其實都印不出 **`A`**，哈哈哈。
{% blockquote %}
因為那時候手上還沒有 Andoird 7.x 的手機啊XD
{% endblockquote %}

沒關係！ **Android SDK** 有出 **Emulator** 可以跑起來測試，為此還多抓了 **Android 7.1** 的 **arm** 的影像檔，可以跑起來但是慢慢的就是。

{% cq %}
所以才趕緊搶隻**便宜手機**，趕緊刷到 **Android 7.1**的嘛！（誤）
{% endcq %}

結果看起來是 **Android** 版本的問題，而不是 **arch** 造成的。
  - **Working**: i686 (tested on **Android 7.1 emulator**)
  - **Not working**: aarch64 (tested on an **Android 6.0 device**)


[之前]: /2017/05/termux-env-setup/tw/#About-Termux
[Termux]: https://termux.com/
[termux-packages]: https://github.com/termux/termux-packages
[Docker]: https://www.docker.com/
[@fornwall]: https://twitter.com/fornwall
[Issue #933]: https://github.com/termux/termux-packages/issues/933
[便宜手機]: http://www.mi.com/tw/redminote4x/
<!-- {% post_link termux-env-setup %} -->
