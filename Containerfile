# Use Ubuntu 22.04 LTS as the base image
FROM ubuntu:22.04 AS pitrac-yocto-builder

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies for Yocto
RUN apt-get update && apt-get install -y \
    file \
    wget \
    bash \
    bmap-tools \
    cpio \
    diffstat \
    gawk \
    git \
    valgrind \
    python3-subunit \
    python3-pip \
    python3-pexpect \
    python3-git \
    python3-jinja2 \
    tar \
    xz-utils \
    locales \
    sudo \
    unzip \
    dos2unix \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download the Yocto Project build tools
RUN wget https://downloads.yoctoproject.org/releases/yocto/yocto-5.0/buildtools/x86_64-buildtools-nativesdk-standalone-5.0.sh \
        && chmod +x x86_64-buildtools-nativesdk-standalone-5.0.sh 

# Install the Yocto Project build tools
RUN ./x86_64-buildtools-nativesdk-standalone-5.0.sh -y -d /tmp/yocto \
        && rm x86_64-buildtools-nativesdk-standalone-5.0.sh

# Set the locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]