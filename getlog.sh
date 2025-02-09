#!/bin/bash

if ! docker create --name tmpenv qtcrossbuild-env; then
    echo "Could not create container"
    exit 1
fi

if ! docker cp tmpenv:/build.log ./env.log; then
    echo "Could not copy logs"
fi

if ! docker rm tmpenv; then
    echo "Could not close container for env"
    exit 1
fi

if ! docker create --name tmpbuild qtcrossbuild-env; then
    echo "Could not create container"
    exit 1
fi

if ! docker cp tmpbuild:/build.log ./build.log; then
    echo "Could not copy logs"
fi

if ! docker rm tmpbuild; then
    echo "Could not close container for build"
    exit 1
fi

exit 0
