#!/bin/bash

if ! docker build -f Dockerfile.app -t qtcrossbuild .; then
    echo "Failed to build docker for qtcrossbuild"
    exit 1
fi

if ! docker create --name tmpbuild qtcrossbuild; then
    echo "Failed to create docker container for qtcrossbuild"
    exit 1
fi

if ! docker cp tmpbuild:/build/project/. ./output/; then
    echo "Failed to copy build from qtcrossbuild"
fi

if ! docker rm tmpbuild; then
    echo "Failed to cleanup container for qtcrossbuild"
    exit 1
fi

exit 0
