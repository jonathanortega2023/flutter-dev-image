# Use Debian as the base image
FROM debian:bookworm-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Build essentials
        build-essential \
        clang \
        cmake \
        ninja-build \
        pkg-config \
        # Development tools
        git \
        curl \
        wget \
        unzip \
        sudo \
        # GTK development
        libgtk-3-dev \
        liblzma-dev \
        # Chrome/Android dependencies
        ca-certificates \
        fonts-liberation \
        libu2f-udev \
        libvulkan1 \
        xdg-utils \
        libasound2 \
        libnspr4 \
        libnss3 \
        # Android SDK (if available in repos)
        android-sdk && \
    # Clean up package cache
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Create non-root user with sudo privileges
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy and execute setup script
COPY setup.sh /setup.sh
RUN chmod +x /setup.sh && \
    /setup.sh

# Switch to non-root user
USER $USERNAME

# Set working directory
WORKDIR /workspace