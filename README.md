# source of https://yumaokao.github.io

# Install Hexo

Install [hexo-cli](https://hexo.io/zh-tw/) with npm
```sh
$ sudo npm install -g hexo-cli
```

If ends up with a npm error `Error: EACCES: permission denied`, from this [issue](https://github.com/hexojs/hexo/issues/2223) try
```sh
$ sudo npm config set unsafe-perm true
```

# Setup Blogs

```sh
$ git clone https://github.com/yumaokao/blogs
$ cd blogs
$ npm install
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```

# Build Blogs
```sh
$ hexo g
$ hexo s
$ hexo d
```
