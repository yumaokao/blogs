.PHONY: all generate service deploy setup
all: generate

setup:
	npm install
	@ [ -d themes/next ] || git clone https://github.com/iissnan/hexo-theme-next themes/next

generate:
	@ [ -f themes/next_config.yml ] && cp themes/next_config.yml ./themes/next/_config.yml
	@ [ -f themes/highlight.styl ] && cp themes/highlight.styl ./themes/next/source/css/_common/components/highlight/highlight.styl
	@ [ -f themes/post.styl ] && cp themes/post.styl ./themes/next/source/css/_common/components/post/post.styl
	@ hexo g

service: generate
	@ hexo s

deploy: generate
	@ hexo d
