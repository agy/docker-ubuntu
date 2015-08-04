CONTAINER := ubuntu

container:
	docker build -t $(CONTAINER) .

tag:
	docker tag $(CONTAINER) $(CONTAINER):$(DRONE_BRANCH)
	docker tag $(CONTAINER) $(CONTAINER):$(DRONE_COMMIT)
