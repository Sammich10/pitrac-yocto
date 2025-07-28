# Use Ubuntu 22.04 LTS as the base image
FROM ubuntu:22.04

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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the PATH to include Yocto tools
ENV PATH="/opt/yocto/x86_64-buildtools-nativesdk-standalone-5.0/bin:${PATH}"

# Set the locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Set the working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]