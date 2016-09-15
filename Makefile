CONTAINER := base
BRANCH := master

container: build

build:
	sudo ./build.sh $(CONTAINER) $(BRANCH)
