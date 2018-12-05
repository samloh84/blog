.PHONY: all build push run

build:
	set -x && \
	jekyll build --incremental

push:
	set -x && \
	git push

run:
	set -x && \
	jekyll serve

all: build push
