# Use a Debian as a parent image
FROM debian

# Prevents prompts from apt.
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils wget unzip git curl clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
    ca-certificates fonts-liberation libu2f-udev libvulkan1 xdg-utils libasound2 libnspr4 libnss3 android-sdk sudo && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user and set permissions
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh
RUN /setup.sh

# Switch back to the vscode user
USER $USERNAME