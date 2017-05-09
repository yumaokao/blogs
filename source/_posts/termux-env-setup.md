---
title: Termux Environment Setup Script
date: 2017-05-08 21:29:00
categories:
- android
- termux
tags:
- android
- termux
- commandline
---

## Termux Environment Setup
因為最近買了一隻想拿來亂玩亂刷 ROM 的手機，每次刷都有可能會清掉裡面所存好的資料，那就會需要重新建立帳號或是環境。
其他的程式可能沒有太大的問題，雖然也沒有使用鈦備份之類的，但大多是登入帳號頂多稍微選個佈景主題之類的就好了，但還是有些需要有比較多設定，就有點麻煩。
{% cq %}
而 **Termux** 的環境設定會是需要花比較多步驟才能達到順手的地步。
{% endcq %}

所以就寫了一個環境設定自動化的 **Script**，以減少設定成本，可以好好來刷機而不用擔心設定好麻煩。
<!-- more -->

## About Termux 
**[Termux]** 是一個在 Android 下的終端機模擬器，但它又附上了一個可以用擴充的套件系統，就像使用一般 [Ubuntu]/[Debian] Linux 一樣，透過 [apt] 這個命令，就可以經由網路安裝或是更新程式了。比起之前用的方法，大致上都是在裡面掛上一個 真正的 **Linux** 影像檔，然後再 **`chroot`** 過去，**[Termux]** 這種明顯跟原本的 Android 系統就比較好的整合性，比如可以在 **[Termux]** 裡面寫 Script 分享網址，或是查詢聯絡人之類的，都可以做得到。


{% cq %}
關於 **Termux** 一定會寫好幾篇的。
{% endcq %}

## Termux Environment Setup Script
因為設定 **Script** 相當個人化，雖然已經儘量減少洩漏但還是有些風險，所以就沒有放出來公開分享。不過還是會把裡面有用到值得一提的部份寫一下。

### Initial script
首先是一開始裝完 **[Termux]** 之後，是一個很乾淨的系統狀態下，要怎麼很快速簡潔又安全地執行一個 **Script** 呢？
就是放到一個自己的網頁位址上，然後用 goo.gl 縮個網址，就可以得到一組很簡單的短網址，像是這樣 **http://goo.gl/123abc**。

而乾淨的 **[Termux]** 系統中，已經有一個 [Busybox] 的 **`wget`** 了，所以只要做這樣就可以：

```sh
$ rm 123abc; wget goo.gl/123abc && bash 123abc
```

### [Y]/n in apt install
接下來要安裝以及更新一些必要的套件，但通常下 **`apt install`** 的命令的時候，都會再問一下說有確定要裝嗎 **`[Y]/n`**？每次都要按個 **`Enter`**，也是有點麻煩。
關於這個部份，**`apt`** 有提供一個參數 **`-y`**，就可以預設是 **yes** 了。

```sh
$ apt upgrade -y
$ apt install -y proot
```

### (yes) and password: in ssh
一樣地，**`ssh`** 與 **`scp`** 命令，也會遇到第一次連線的時候，會需要輸入 **`(yes)`**，已建立新的連線。而在還沒有把 **private key** 抓回來之前，也會需要輸入一次密碼，遇到了就會停下來等待輸入才有辦法繼續，不太自動。

所以會在一開始的時候，就先把密碼問一下，然後再利用 **`sshpass`** 這個工具來解決第一次需要密碼的問題。
而第一次的連線的時候，可以下 **StrictHostKeyChecking=no** 參數，避免要等待輸入 **`(yes)`**。

```sh
echo "Please input password for the first time"
read -s P

[ -f $HOME/.ssh/id_rsa ] && SSHPASS="" || SSHPASS="sshpass -p $P"
$SSHPASS ssh -o StrictHostKeyChecking=no sshserver ls
```

### Here document to config file
因為 **[Termux]** 環境跟 [Ubuntu]/[Debian] Linux 環境還是有點不一樣，有些程式所參考的位置，在 **[Termux]** 就不一定會出現。
像是 **`/etc/shells`** 這個檔案會紀錄著 Linux 系統中所有可能的 shells，而 [oh-my-zsh] 安裝的時候會檢查這個檔案中有沒有 [zsh]，不然就不裝了。

只好自己產生一個：
```sh
# shells
cat > /etc/shells <<EOF
# /etc/shells: valid login shells
/bin/sh
/bin/bash
/usr/bin/tmux
/bin/zsh
/use/bin/zsh
EOF
```

## Multiple stages before/after chroot
好的，問題來了。
如果進去到 **[Termux]** 的視窗中，就會發現它的確還是在 **Android** 底下，不信可以先 **`ls /`** 看看，完全就是個 **Android** **根目錄**的樣子。

### shebang
這代表一件事，如果沒有特別處理，開頭長得像這樣的 **Script** 是沒有辦法直接執行的。
```sh
#!/bin/sh
```
這東西有個專有名詞叫作 **[Shebang]**。


**[Termux]** 有提供一個指令 **`termux-fix-shebang`**，它會自動把上面的 **Shebang** 改成 **[Termux]** 的路徑：
```sh
#!/data/data/com.termux/files/user/bin/bash
```

### chroot
{% blockquote %}
但是每個 **Script** 都需要 **fix** 的話，相當不好用啊。
{% endblockquote %}
所以 [Termux] 也有另外一個指令 **`termux-chroot`**，是基於 **`proot`** 包裝成的 **chroot** 環境，其實就是把**根目錄**換成剛剛的 **/data/data/com.termux/files**。
```sh
$ termux-chroot
$ ls /
bin dev home proc storage tmp var
data etc lib share system usr
```

### chroot in script
在安裝個人環境的 **Setup Script**，會需要進入到 **`termux-chroot`** 環境中的，不然會遇到路徑找不到的錯誤，像是用 **`repo init -u `** 的時候，就會有問題。

但是直接寫在 **`termux-chroot`** 後面命令，是不會被執行到的，更正確地說，是離開了 **chroot** 環境才會繼續執行下去。
```sh
$ cat setup.sh
...
termux-chroot
ls /
```

這很常見，因為 **`termux-chroot`** 會產生一個互動的 **login shell**。
通常 **`chroot`** 會可以接受參數，指定新環境下要跑的命令。
```sh
$ chroot --help
Usage: chroot [OPTION] NEWROOT [COMMAND [ARG]...]
```

不過 **`termux-chroot`** 就不允許這樣了，看了一下原始碼，是不接受參數的。
```sh
if [ $# != 0 ]; then
	echo "termux-chroot: Setup a chroot to mimic a normal Linux file system"
	echo ""
	echo "Execute without arguments to run a chroot with traditional file system"
	echo "hierarchy (having e.g. the folders /bin, /etc and /usr) within Termux."
	exit
fi

...

ARGS="$ARGS $PROGRAM -l"

export HOME=/home
$PREFIX/bin/proot $ARGS
```

雖然 **`termux-chroot`** 不行，但原始碼看得出來 **`proot`** 是可以指定 **$PROGRAM** 等等命令的，
因此只要照抄 **`termux-chroot`** 的前面部份，獲得到 **$ARGS** 變數，換成自己的，就可以寫在 **Script** 自動執行 **chroot** 後的命令了。


### mutiple stages
所以最後的 **Setup Script** 架構大概長成這樣子，分成兩階段執行，這樣就可以放下去跑，然後休息一下，等它們全部設定完就好了。

```sh
zero() {
  # before termux-chroot
  apt install proot

  ...

  prepare-termux-chroot
  export HOME=/home
  $PREFIX/bin/proot $ARGS /bin/bash $0 1

}

first() {
  # after termux-chroot
  ls /
}

if [ $# -eq 0 ]; then
  zero
fi
if [ $# -eq 1 ]; then
  first
fi
```


[Termux]: https://termux.com/
[apt]: https://en.wikipedia.org/wiki/Advanced_Packaging_Tool
[Ubuntu]: https://www.ubuntu.com/
[Debian]: https://www.debian.org/
[Busybox]: https://www.busybox.net/
[oh-my-zsh]: http://ohmyz.sh/
[zsh]: http://www.zsh.org/
[Shebang]: https://zh.wikipedia.org/wiki/Shebang
