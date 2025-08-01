#!/bin/bash

print_usage() {
    echo "Usage: $0 [-c|--clean] [-i|--image <image_name>] [-h|--help]"
    echo "Options:"
    echo "  -c, --clean          Clean the temp directory and optionally prune old sstate-cache files. Can be specified up to 3 times for different levels of cleaning."
    echo "  -i, --image <name>   Specify the image to build (default: core-image-minimal)"
    echo "  --no-build           Do not run the bitbake build process"
    echo "  --build-sdk          Build the SDK instead of the image"
    echo "  --copy-image         Copy the completed image to an SD card"
    echo "  --image-dev          Specify the device to place the image on"
    echo "  -h, --help           Show this help message"
    exit 1
}

# Default values
CLEAN=0
IMAGE="pitrac-image-base"
BUILD=1
SDK=0
# Default device for copying the image
IMG_DEV="/dev/sde1"
COPY_IMG=0
# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--clean)
            CLEAN=($((CLEAN + 1)))
            shift
            ;;
        -i|--image)
            IMAGE="$2"
            shift 2
            ;;
        -n|--no-build)
            BUILD=0
            shift
            ;;
        --copy-image)
            COPY_IMG=1
            shift
            ;;
        --image-dev)
            IMG_DEV="$2"
            shift 2
            ;;
        --build-sdk)
            SDK=1
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

if [[ $CLEAN -gt 0 ]]; then
    echo "Cleaning temp directory..."
    rm -rf tmp/
fi

if [[ $CLEAN -gt 1 ]]; then
    echo "Pruning old sstate-cache files..."
    find sstate-cache -type f -mtime +30 -delete
fi

if [[ $CLEAN -gt 2 ]]; then
    echo "Cleaning sstate for all recipes"
    bitbake -c cleanall worldz
fi

if [[ ! -d "buildlogs" ]]; then
    mkdir buildlogs
fi

timestamp=$(date +%Y-%m-%d_%H:%M:%S)
echo "Building image: ${IMAGE}. Build start at {$timestamp}"
bitbake $IMAGE | tee buildlogs/build_${timestamp}.log

if [[ $SDK -eq 1 ]]; then
    echo "Building SDK..."
    bitbake pitrac-image-base -c populate_sdk
    echo "SDK build completed."
fi

if [[ $COPY_IMG -eq 1 ]]; then
    # Check if the image device is mounted
    if mount | grep -q ${IMG_DEV}; then
        echo "Unmounting ${IMG_DEV}..."
        sudo umount ${IMG_DEV}
    fi
    # Use bmaptool to create the SD card image for the Pi
    sudo bmaptool copy ${IMAGE}-raspberrypi5.rootfs.wic.bz2 ${IMG_DEV}
fi