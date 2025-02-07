#!/bin/bash

# Build extended sysroot
if [ -d "sysroot" ]; then
    cd sysroot
    tar cfz ../sysroot.tar.gz ./*
    cd ../
fi

if ! docker build -t qtcrossbuild-env .; then
    echo "Failed to build docker for qtcrossbuild-env"
    return false
fi

if ! docker create --name tmpbuild qtcrossbuild-env; then
    echo "Failed to create docker container for qtcrossbuild-env"
    return false
fi

if ! docker cp tmpbuild:/build/project/. ./output/; then
    echo "Failed to copy build from qtcrossbuild-env"
fi

if ! $(docker rm tmpbuild); then
    echo "Failed to cleanup container for qtcrossbuild-env"
    return false
fi
