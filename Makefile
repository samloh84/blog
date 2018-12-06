.PHONY: all build push serve

build:
	set -x && \
	bundle exec jekyll build

push:
	set -x && \
	git push

serve:
	set -x && \
	bundle exec jekyll serve

all: build push
