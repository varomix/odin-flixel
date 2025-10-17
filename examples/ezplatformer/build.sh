#!/bin/bash

# Build script for EZPlatformer example

echo "Building EZPlatformer..."

# Build the example
odin build . -out:ezplatformer -debug

if [ $? -eq 0 ]; then
    echo "Build successful! Run with ./ezplatformer"
else
    echo "Build failed!"
    exit 1
fi
