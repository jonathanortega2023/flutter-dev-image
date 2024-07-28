#!/bin/bash

set -e

USER=vscode
ANDROID_SDK_DIR="/usr/lib/android-sdk"
CMDLINE_TOOLS_DIR="$ANDROID_SDK_DIR/cmdline-tools"
BUILD_TOOLS_VERSION="34.0.0"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
FLUTTER_DIR="/usr/lib/flutter"
FLUTTER_GIT_URL="https://github.com/flutter/flutter.git"
CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

# Install cmdline-tools if not already installed
if [ ! -d "$CMDLINE_TOOLS_DIR" ]; then
    echo "Installing cmdline-tools in ${CMDLINE_TOOLS_DIR}..."
    wget $CMDLINE_TOOLS_URL -O commandlinetools.zip
    unzip commandlinetools.zip -d /tmp/cmdline-tools
    mkdir -p $CMDLINE_TOOLS_DIR/latest
    mv /tmp/cmdline-tools/cmdline-tools/* $CMDLINE_TOOLS_DIR/latest/
    rm -rf /tmp/cmdline-tools commandlinetools.zip
    ln -sf $CMDLINE_TOOLS_DIR/latest/bin/sdkmanager /usr/sbin/sdkmanager
    ln -sf $ANDROID_SDK_DIR/platform-tools/adb /usr/sbin/adb
    echo "cmdline-tools installed and linked"
fi

# Remove inconsistent build-tools directories
if [ -d "$ANDROID_SDK_DIR/build-tools/debian" ]; then
    rm -rf "$ANDROID_SDK_DIR/build-tools/debian"
fi
if [ -d "$ANDROID_SDK_DIR/build-tools/29.0.3" ]; then
    rm -rf "$ANDROID_SDK_DIR/build-tools/29.0.3"
fi
echo "Removed inconsistent build-tools dirs"

yes | sdkmanager "build-tools;$BUILD_TOOLS_VERSION"

# Update and accept licenses
yes | sdkmanager --update
yes | sdkmanager --licenses


# Install latest platform
latest_platform=$(yes | sdkmanager --list | grep "platforms;android-" | sort -V | tail -1 | awk '{print $1}')
yes | sdkmanager "$latest_platform"
chown -R $USER:$USER $ANDROID_SDK_DIR
echo "Installed latest platform"

# Install Chrome if not already installed
if [ ! -x "/usr/bin/google-chrome" ]; then
    wget $CHROME_URL -O google-chrome.deb
    apt install -y ./google-chrome.deb
    rm google-chrome.deb
    echo "Chrome installed"
else
    echo "Chrome already installed"
fi

# Install Flutter if not already installed
if [ ! -d "$FLUTTER_DIR" ]; then
    git clone $FLUTTER_GIT_URL -b stable $FLUTTER_DIR
    ln -sf $FLUTTER_DIR/bin/dart /usr/sbin/dart
    ln -sf $FLUTTER_DIR/bin/flutter /usr/sbin/flutter
    flutter precache
    chown -R $USER:$USER $FLUTTER_DIR
    echo "Flutter installed and linked"
else
    echo "Flutter already installed"
fi

# Configure Flutter for web and mobile
flutter config --no-enable-linux-desktop
flutter config --no-enable-macos-desktop
flutter config --no-enable-windows-desktop
echo "Flutter configured for web and mobile"
flutter doctor

# Optionally install Firebase CLI and FlutterFire CLI
if [ "$INSTALL_FLUTTERFIRE" = "true" ]; then
    if [ ! -f /usr/lib/firebase ]; then
        wget -O /usr/lib/firebase https://firebase.tools/bin/linux/latest
        chmod +x /usr/lib/firebase
        chown $USER:$USER /usr/lib/firebase
        ln -sf /usr/lib/firebase /usr/sbin/firebase
        firebase login
        dart pub global activate flutterfire_cli
        echo "Firebase CLI and FlutterFire CLI installed"
    else
        echo "Firebase CLI already installed"
    fi
fi