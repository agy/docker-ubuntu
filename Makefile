CONTAINER := ubuntu
WORKDIR ?= .

container:
	cd $(WORKDIR) && docker build -t $(CONTAINER) .
