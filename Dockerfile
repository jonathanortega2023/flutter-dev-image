FROM debian:bookworm-slim

# Optional flutterfire tools installation
ARG FLUTTERFIRE=false

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_DIR=/usr/lib/android-sdk
ENV CMDLINE_TOOLS_DIR=$ANDROID_SDK_DIR/cmdline-tools
ENV FLUTTER_DIR=/usr/lib/flutter
ENV PATH=$FLUTTER_DIR/bin:$ANDROID_SDK_DIR/cmdline-tools/latest/bin:$ANDROID_SDK_DIR/platform-tools:$PATH

# -------------------------
# Create non-root user
# -------------------------
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# -------------------------
# Install system dependencies
# -------------------------
RUN apt-get update --fix-missing && apt-get install -y --no-install-recommends \
    build-essential clang cmake ninja-build pkg-config \
    git curl wget unzip xz-utils zip libglu1-mesa \
    libgtk-3-dev liblzma-dev mesa-utils \
    ca-certificates fonts-liberation libu2f-udev libvulkan1 xdg-utils libasound2 libnspr4 libnss3 \
    android-sdk \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# -------------------------
# Install Google Chrome
# -------------------------
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb \
    && apt-get install -y /tmp/chrome.deb \
    && rm /tmp/chrome.deb \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
    && chown -R $USER_UID:$USER_GID /usr/bin/google-chrome

# -------------------------
# Install Flutter SDK
# -------------------------
RUN git config --system --add safe.directory $FLUTTER_DIR \
    && git clone -b stable https://github.com/flutter/flutter.git $FLUTTER_DIR \
    && chown -R $USER_UID:$USER_GID $FLUTTER_DIR

# -------------------------
# Install Android SDK command-line tools
# -------------------------
RUN mkdir -p $ANDROID_SDK_DIR/cmdline-tools/latest \
    && curl -sSL https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -o /tmp/cmdline-tools.zip \
    && unzip /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && mv /tmp/cmdline-tools/cmdline-tools/* $ANDROID_SDK_DIR/cmdline-tools/latest/ \
    && rm -rf /tmp/cmdline-tools /tmp/cmdline-tools.zip \
    && yes | sdkmanager --update \
    && yes | sdkmanager --licenses \
    && yes | sdkmanager "platform-tools" "build-tools;35.0.0" \
    && yes | sdkmanager $(sdkmanager --list | grep -v "-ext" | grep -E "platforms;android-[0-9]{2}" | sort -V | tail -1 | awk '{print $1}') \
    && chown -R $USER_UID:$USER_GID $ANDROID_SDK_DIR

# -------------------------
# Install Firebase CLI and FlutterFire CLI (optional)
# -------------------------
RUN if [ "$FLUTTERFIRE" = "true" ]; then \
    wget -O /usr/lib/firebase https://firebase.tools/bin/linux/latest && \
    chmod +x /usr/lib/firebase && \
    chown $USER_UID:$USER_GID /usr/lib/firebase && \
    ln -sf /usr/lib/firebase /usr/sbin/firebase; \
    fi

WORKDIR /workspace
USER $USERNAME

RUN if [ "$FLUTTERFIRE" = "true" ]; then \
    dart pub global activate flutterfire_cli; \
    fi

# -------------------------
# Configure Flutter as the vscode user
# -------------------------
RUN flutter precache