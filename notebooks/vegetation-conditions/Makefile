BASE_DIR := $(shell pwd)
all: build serve
build:
	jupyter-book build . --config docs/_config.yml --toc docs/_toc.yml
	
serve:
	echo "Enter Serve" && \
	BASE_DIR=$$(cd $(CURDIR) && pwd) && \
	echo "Base Directory: $$BASE_DIR" && \
	FULL_PATH="$$BASE_DIR/_build/html/index.html" && \
	echo "Full Path: $$FULL_PATH" && \
	start chrome "$$FULL_PATH"