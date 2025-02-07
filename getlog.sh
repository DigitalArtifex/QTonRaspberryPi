#!/bin/bash

if docker create --name tmpbuild qtcrossbuild; then
    docker cp tmpbuild:/build.log ./build.log
    docker rm tmpbuild
fi
