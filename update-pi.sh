#!/bin/bash

if ! docker buildx build --platform linux/arm64 --load -f DockerFileRasp -t raspimage $PWD; then
    echo "Could not create virtual env for Raspberry Pi"
    exit 1
fi

if ! docker create --name temp-arm raspimage; then
    echo "Could not create Raspberry Pi docker image"
    exit 1
fi

if ! docker cp temp-arm:/build/rasp.tar.gz ./sysroot-base.tar.gz; then
    echo "Could not copy sysroot of Raspberry Pi"
    exit 1
fi

if ! docker rm /temp-arm; then
    echo "Could not remove container"
    exit 1
fi

exit 0
