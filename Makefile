CONTAINER := ubuntu
WORKDIR := .

ifdef $$DRONE_BUILD_DIR
WORKDIR := $$DRONE_BUILD_DIR
endif

container:
	cd $(WORKDIR)
	docker build -t $(CONTAINER) .
