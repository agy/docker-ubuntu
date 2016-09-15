FROM ubuntu:16.04

ADD ./etc /etc

RUN apt-get update && \
    apt-get dist-upgrade --yes && \
    DEBIAN_FRONTEND=noninteractive \
        apt-get install --yes \
            apt-transport-https \
            ca-certificates && \
    rm -rf /var/lib/apt/lists/*
