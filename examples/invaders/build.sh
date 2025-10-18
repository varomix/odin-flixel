#!/bin/bash

echo "Building Flx Invaders..."
export PATH="/Users/varomix/dev/ODIN_DEV/Odin:$PATH"
odin build . -out:invaders -debug
if [ $? -eq 0 ]; then
    echo "Build successful! Run with ./invaders"
else
    echo "Build failed!"
    exit 1
fi
