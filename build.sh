#!/bin/bash

if docker build -t qtcrossbuild .; then
    if docker create --name tmpbuild qtcrossbuild; then
        docker cp tmpbuild:/build/project/. ./output/
        docker rm tmpbuild
    fi
fi
