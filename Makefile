.PHONY: all build push run

build:
	set -x && \
	bundle exec jekyll build --incremental

push:
	set -x && \
	git push

run:
	set -x && \
	bundle exec jekyll serve

all: build push
