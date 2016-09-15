CONTAINER := base
BRANCH := master

container: build

build:
	./build.sh $(CONTAINER) $(BRANCH)
