#!/bin/bash

if ! docker create --name tmpbuild qtcrossbuild-env; then
    echo "Could not create container"
    exit 1
fi

if ! docker cp tmpbuild:/build.log ./build.log; then
    echo "Could not copy logs"
fi

if ! docker rm tmpbuild; then
    echo "Could not close container"
    exit 1
fi

exit 0
