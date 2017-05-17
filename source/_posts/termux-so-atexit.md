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
```sh
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
因為那時候手上還沒有 **Andoird 7.x** 的手機啊XD
{% endblockquote %}

沒關係！ **Android SDK** 有出 **Emulator** 可以跑起來測試，為此還多抓了 **Android 7.1** 的 **arm** 的影像檔，可以跑起來但是慢慢的就是。
{% blockquote %}
順便該一下，現在要開新的 **avd** 都不能直接用 **`android`**了，很麻煩耶。
{% endblockquote %}

{% cq %}
所以才趕緊搶隻**便宜手機**，趕緊刷到 **Android 7.1** 的嘛！（誤）
{% endcq %}

測試結果看起來是 **Android** 版本的問題，而不是 **arch** 造成的。
  - **Working**: i686 (tested on **Android 7.1 emulator**)
  - **Not working**: aarch64 (tested on an **Android 6.0 device**)

好的，釐清了會發生問題的條件後，就來研究一下 **`libgpg-error`** 如何處理 **`es_putc`**，簡單看過之後，大致上就是有個 **estream** 自行實現了 **buffered** 字串流功能，會等到 **buffer** 滿了之後再一塊刷出到 **fd**，像是 **stdout** 或是 **stderr**。

那要是主程式程式要離開了，但 **buffer** 裡面還有東西該怎麼辦呢？這時候會需要有個收尾的 **function** 來把還沒刷出去的給印出來，不然就會覺得被吃掉了。

{% blockquote %}
這個收尾的 **function** 就叫作 **`do_deinit()`**，是透過 **libc** 的 **`atexit()`** 註冊的。
{% endblockquote %}

### abort()
馬上就來在 **`do_deinit()`** 前面很趕緊加個 **`fprintf(stderr)`**，看看能不能印出東西來代表有沒有跑到。結果是不行的，沒有看到訊息被印出來，所以直覺地認為在有問題的手機上 **`do_deinit`** 是沒有被跑到的。

那就來看看會跑到的手機，是怎麼進去這個收尾 **`do_deinit()`** 呢？加個 **`abort()`** 在剛剛的 **`fprintf(stderr)`** 之後吧，這樣就可以得到 **core dump** 了，有這個就可以 **`bt`**看是誰叫到了。

**[Termux]** 很讚是，已經有 **`gdb`** 可以裝了，接著有疑問的地方是剛剛程式不是用 **`clang`** 編譯的嗎？這樣也可以用 **`gdb`** 嗎？其實是可以的啦。

{% blockquote %}
結果有問題的手機，也是會 **`abort`** 的，這表示都有跑到 **`do_deinit()`**
{% endblockquote %}

### stdin, stdout and stderr
看起來是 **`do_deinit()`** 有被叫到，但是 **`fprintf`** 沒有辦法印出東西來，這太有趣了！什麼時候會遇到 **`printf`** 沒有辦法正常工作呢？
{% blockquote %}
**`printf`** 可以說是 **debug** 的第一步啊XD
{% endblockquote %}

既然有 **`gdb`** 了，那來中斷在 **`do_deinit()`** 的進入點上，看看這時候 **/proc/PID/fd/** 有哪裡不一樣吧。

```sh
$ gdb ./issue933
(gdb) b do_deinit
(gdb) r

# On Not-working Devices
$ ls -l /proc/3965/fd

# On Working Devices
$ ls -l /proc/28326/fd
total 0
lrwx------ 1 u0_a101 u0_a101 64 May 17 11:32 0 -> /dev/pts/1
lrwx------ 1 u0_a101 u0_a101 64 May 17 11:32 1 -> /dev/pts/1
lrwx------ 1 u0_a101 u0_a101 64 May 17 11:32 2 -> /dev/pts/1
```

{% cq %}
**stdin, stdout, stderr** 在這時候已經被清掉了啊啊啊啊XDDD
{% endcq %}

### Test Code: termux-so-atexit
為了更加簡單釐清問題，寫了一個很基本的測試程式 **[termux-so-atexit]** 來驗證會造成 **stdout** 消失的原因。**[termux-so-atexit]** 會儘量把環境一步步逼近跟 **[Issue #933]** 一樣，這樣就可以知道是什麼部份差異所造成的。

只要有裝好 **[Termux]** 可以很容易安裝以及跑這個測試程式。
```sh
$ apt install hub
$ hub clone yumaokao/termux-so-atexit
$ cd termux-so-atexit

# On Not-working Devices
$ make test_atexit-so-constructor
Should see messages and aborted
make: *** [Makefile:15: test_atexit-so-constructor] Aborted

# On Working Devices
$ make test_atexit-so-constructor
Should see messages and aborted
atexit called from shared library
make: *** [Makefile:15: test_atexit-so-constructor] Aborted
```

### __attribute__ ((__constructor__))
經過了 **[termux-so-atexit]** 的逼近，確定只要符合底下的條件，就會發生 **stdout** 消失的問題。
  1. 使用 **`Android 7.0`** 以前的版本
  1. **`atexit()`** 是在被宣告有 **`__attribute__ ((__constructor__))`** 的函數裡呼叫的

**`libgpg-error`** 就是這樣，它會判斷編譯器是不是支援 **`__attribute__ ((__constructor__))`**

```c
/* gpg-error.h */

#if _GPG_ERR_GCC_VERSION > 30100
# define _GPG_ERR_CONSTRUCTOR	__attribute__ ((__constructor__))
# define _GPG_ERR_HAVE_CONSTRUCTOR
#else
# define _GPG_ERR_CONSTRUCTOR
#endif

/* Initialize the library.  This function should be run early.  */
gpg_error_t gpg_err_init (void) _GPG_ERR_CONSTRUCTOR;
```

而 **`gpg_err_init()`** 最後會叫到 **`_gpgrt_estream_init()`**，終於在這裡註冊了 **`atexit`**。
```c
/* estream.c */

int
_gpgrt_estream_init (void)
{
  static int initialized;

  if (!initialized)
    {
      initialized = 1;
      atexit (do_deinit);
    }
  return 0;
}
```

### Workaround PR #1017
知道是這個 **`__attribute__ ((__constructor__))`** 造成的，那要怎麼避開這個問題呢？

首先先來看看要是平台不支援這種 **__constructor__** 的話， **`libgpg-error`** 會如何處理。
```c
/* gpg-error.h */

/* If this is defined, the library is already initialized by the
   constructor and does not need to be initialized explicitely.  */
#undef GPG_ERR_INITIALIZED
#ifdef _GPG_ERR_HAVE_CONSTRUCTOR
# define GPG_ERR_INITIALIZED	1
# define gpgrt_init() do { gpg_err_init (); } while (0)
#else
# define gpgrt_init() do { ; } while (0)
#endif
```
{% cq %}
個人認為這邊是寫錯的，**gpgrt_init()** 的定義應該反過來才對啊？！
{% endcq %}

好吧，**將錯就錯**！反正現在即使有 **`__attribute__ ((__constructor__))`** 也還是會再進去 **`_gpgrt_estream_init()`** 一次就是。

{% cq %}
那麼就改成可以再註冊一次 **`atexit(do_deinit)`** 就可以了！（神奇吧！哈哈！）
{% endcq %}
底下就是送出去給 **[termux-packages]** 的 **Pull Request** **[PR #1017]**
```diff
 {
    static int initialized;

 +#ifdef __ANDROID__
 +  if (initialized < 2)
 +#else
    if (!initialized)
 +#endif
      {
        initialized = 1;
        atexit (do_deinit);
```

### Executed Order of atexit()
為什麼這樣修正 **([PR #1017])** 就可以正常印出字串到 **stdout** 了呢？根據 **`atexit()`** 的 **manual** 所描述
{% blockquote %}
Functions so registered are called in the **`reverse order`** of their registration;
{% endblockquote %}

簡單地說就是個 **Stack** 或是 **First In Last Out** 的架構。

所以進入 **main()** 後再被註冊的 **`do_deinit()`** 會先被執行到，而這時候 **stdout, stderr** 等的 **fd** 還在，就可以正常刷出還在 **buffer** 裡的字串到螢幕上了。

**[PR #1017]** 很快就被 **merged** 了，即使還是個 **workaround**，但跟原本的比起來，至少在一處做比多個用到 **libgpg-error** 的地方改還乾淨一點。

[之前]: /2017/05/termux-env-setup/tw/#About-Termux
[Termux]: https://termux.com/
[termux-packages]: https://github.com/termux/termux-packages
[Docker]: https://www.docker.com/
[@fornwall]: https://twitter.com/fornwall
[Issue #933]: https://github.com/termux/termux-packages/issues/933
[PR #1017]: https://github.com/termux/termux-packages/pull/1017
[便宜手機]: http://www.mi.com/tw/redminote4x/
[termux-so-atexit]: https://github.com/yumaokao/termux-so-atexit
[commit bb46afd]: https://android.googlesource.com/platform/bionic/+/bb46afd%5E!/
<!-- {% post_link termux-env-setup %} -->
## Root Cause: bionic C
{% cq %}
有沒有發現，上面講了這麼多，其實真正的原因還沒找到耶！（驚）
{% endcq %}

好吧，所以來找找看關於 **`atexit()`** 這邊的 **flow** 是不是有相關的變動，不然怎麼會新的 **Android 7.x** 就沒問題了呢。

個人認為在 **`bionic`** 的這個 **[commit bb46afd]** 是造成 **[Issue #933]** 最根本的原因。
