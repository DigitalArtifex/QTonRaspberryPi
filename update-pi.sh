#!/bin/bash

if docker buildx build --platform linux/arm64 --load -f DockerFileRasp -t raspimage $PWD; then

    if docker create --name temp-arm raspimage; then
        docker cp temp-arm:/build/rasp.tar.gz ./sysroot-base.tar.gz
        docker rm /temp-arm
    fi
fi
