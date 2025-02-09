#!/bin/bash

# Build extended sysroot
if [ -d "sysroot-ext" ]; then
    cd sysroot-ext
    tar cfz ../sysroot-ext.tar.gz ./*
    cd ../
fi

if ! docker build -t qtcrossbuild-env .; then
    echo "Failed to build docker for qtcrossbuild-env"
    exit 1
fi

exit 0
