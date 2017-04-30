.PHONY: all generate service deploy setup theme
all: generate

setup:
	npm install
	@ [ -d themes/next ] || git clone https://github.com/iissnan/hexo-theme-next themes/next

theme:
	@ [ -f themes/next_config.yml ] && cp themes/next_config.yml ./themes/next/_config.yml
	@ [ -f themes/next_custom.styl ] && cp themes/next_custom.styl ./themes/next/source/css/_custom/custom.styl
	# @ [ -f themes/highlight.styl ] && cp themes/highlight.styl ./themes/next/source/css/_common/components/highlight/highlight.styl
	# @ [ -f themes/post.styl ] && cp themes/post.styl ./themes/next/source/css/_common/components/post/post.styl

generate: theme
	@ hexo g

service: generate
	@ hexo s

deploy: generate
	@ hexo d
