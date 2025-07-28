#!/bin/bash

print_usage() {
    echo "Usage: $0 [-c|--clean] [-i|--image <image_name>] [-h|--help]"
    echo "Options:"
    echo "  -c, --clean          Clean the temp directory and optionally prune old sstate-cache files. Can be specified up to 3 times for different levels of cleaning."
    echo "  -i, --image <name>   Specify the image to build (default: core-image-minimal)"
    echo "  -h, --help           Show this help message"
    exit 1
}

CLEAN=0
IMAGE="core-image"
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
    bitbake -c cleanall world
fi

if [[ ! -d "buildlogs" ]]; then
    mkdir buildlogs
fi

timestamp=$(date +%Y-%m-%d_%H:%M:%S)
echo "Building image: ${IMAGE}. Build start at {$timestamp}"
bitbake $IMAGE | tee buildlogs/build_${timestamp}.log
if [[ $? -eq 0 ]]; then
    echo "Build completed successfully. Output saved to build_${timestamp}.log"
    echo "You can find the built image in tmp/deploy/images/"
    exit 0
else
    echo "Build failed. Check build_${timestamp}.log for details."
    exit 1
fi
