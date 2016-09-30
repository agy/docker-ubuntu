CONTAINER := base

container: build

build:
	./build.sh $(CONTAINER)
