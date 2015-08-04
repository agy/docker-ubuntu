CONTAINER := ubuntu

container:
	docker build -t $(CONTAINER) .
