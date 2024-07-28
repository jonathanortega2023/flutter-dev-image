# Use an Ubuntu as a parent image
FROM debian

# Prevents prompts from apt.
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils wget unzip git curl clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
    ca-certificates fonts-liberation libu2f-udev libvulkan1 xdg-utils libasound2 libnspr4 libnss3 android-sdk && \
    rm -rf /var/lib/apt/lists/*

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh