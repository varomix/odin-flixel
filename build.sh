#!/bin/bash

# Mix Motor Build Script
# Simple build helper for the game framework

set -e  # Exit on error

echo "🎮 Mix Motor Build Script"
echo "========================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
BUILD_MODE="debug"
RUN_AFTER=false
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--release)
            BUILD_MODE="release"
            shift
            ;;
        -d|--debug)
            BUILD_MODE="debug"
            shift
            ;;
        --run)
            RUN_AFTER=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            echo "Usage: ./build.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --debug     Build in debug mode (default)"
            echo "  -r, --release   Build in release mode"
            echo "  --run           Run after building"
            echo "  --clean         Clean build artifacts"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}🧹 Cleaning build artifacts...${NC}"
    rm -f mix_motor
    rm -rf mix_motor.dSYM
    echo -e "${GREEN}✓ Clean complete${NC}"
    exit 0
fi

# Build
echo -e "${YELLOW}🔨 Building in $BUILD_MODE mode...${NC}"

# Add Odin to PATH
export PATH="/Users/varomix/dev/ODIN_DEV/Odin:$PATH"

if [ "$BUILD_MODE" = "release" ]; then
    odin build . -o:speed -no-bounds-check
else
    odin build . -debug
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build successful!${NC}"

    # Show file size
    if [ -f "./mix_motor" ]; then
        SIZE=$(ls -lh ./mix_motor | awk '{print $5}')
        echo -e "${GREEN}  Binary size: $SIZE${NC}"
    fi

    # Run if requested
    if [ "$RUN_AFTER" = true ]; then
        echo -e "${YELLOW}🚀 Running Mix Motor...${NC}"
        echo ""
        ./mix_motor
    fi
else
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi
