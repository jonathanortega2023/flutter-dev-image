#!/bin/bash
#
# Flutter Development Environment Setup Script
# Installs Flutter SDK, Android SDK tools, and Chrome for development
#

set -e

# Configuration variables
export DEBIAN_FRONTEND=noninteractive
readonly USER="vscode"
readonly ANDROID_SDK_DIR="/usr/lib/android-sdk"
readonly CMDLINE_TOOLS_DIR="$ANDROID_SDK_DIR/cmdline-tools"
readonly BUILD_TOOLS_VERSION="35.0.0"
readonly CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
readonly FLUTTER_DIR="/usr/lib/flutter"
readonly FLUTTER_GIT_URL="https://github.com/flutter/flutter.git"
readonly CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

# Configure git safe directory for Flutter
git config --system --add safe.directory "$FLUTTER_DIR"

echo "=== Starting Flutter Development Environment Setup ==="

# Install Android SDK command-line tools
install_android_cmdline_tools() {
    if [ ! -d "$CMDLINE_TOOLS_DIR" ]; then
        echo "Installing Android SDK command-line tools..."
        wget "$CMDLINE_TOOLS_URL" -O commandlinetools.zip
        unzip commandlinetools.zip -d /tmp/cmdline-tools
        mkdir -p "$CMDLINE_TOOLS_DIR/latest"
        mv /tmp/cmdline-tools/cmdline-tools/* "$CMDLINE_TOOLS_DIR/latest/"
        rm -rf /tmp/cmdline-tools commandlinetools.zip
        ln -sf "$CMDLINE_TOOLS_DIR/latest/bin/sdkmanager" /usr/sbin/sdkmanager
        ln -sf "$ANDROID_SDK_DIR/platform-tools/adb" /usr/sbin/adb
        echo "✓ Android SDK command-line tools installed"
    else
        echo "✓ Android SDK command-line tools already installed"
    fi
}

install_android_cmdline_tools

# Configure Android SDK
configure_android_sdk() {
    echo "Configuring Android SDK..."
    
    # Remove inconsistent build-tools directories
    [ -d "$ANDROID_SDK_DIR/build-tools/debian" ] && rm -rf "$ANDROID_SDK_DIR/build-tools/debian"
    [ -d "$ANDROID_SDK_DIR/build-tools/29.0.3" ] && rm -rf "$ANDROID_SDK_DIR/build-tools/29.0.3"
    
    # Install build tools and accept licenses
    yes | sdkmanager "build-tools;$BUILD_TOOLS_VERSION"
    yes | sdkmanager --update
    yes | sdkmanager --licenses >/dev/null 2>&1
    
    # Install latest Android platform
    local latest_platform
    latest_platform=$(yes | sdkmanager --list | grep -E "platforms;android-[0-9]{2}" | grep -v "-ext" | sort -V | tail -1 | awk '{print $1}')
    yes | sdkmanager "$latest_platform"
    
    # Set proper ownership
    chown -R "$USER:$USER" "$ANDROID_SDK_DIR"
    echo "✓ Android SDK configured with latest platform: $latest_platform"
}

configure_android_sdk

# Install Google Chrome
install_chrome() {
    if [ ! -x "/usr/bin/google-chrome" ]; then
        echo "Installing Google Chrome..."
        wget "$CHROME_URL" -O google-chrome.deb
        apt install -y ./google-chrome.deb
        rm google-chrome.deb
        echo "✓ Google Chrome installed"
    else
        echo "✓ Google Chrome already installed"
    fi
}

install_chrome

# Install and configure Flutter
install_flutter() {
    if [ ! -d "$FLUTTER_DIR" ]; then
        echo "Installing Flutter SDK..."
        git clone "$FLUTTER_GIT_URL" -b stable "$FLUTTER_DIR"
        ln -sf "$FLUTTER_DIR/bin/dart" /usr/sbin/dart
        ln -sf "$FLUTTER_DIR/bin/flutter" /usr/sbin/flutter
        flutter precache
        chown -R "$USER:$USER" "$FLUTTER_DIR"
        echo "✓ Flutter SDK installed"
    else
        echo "✓ Flutter SDK already installed"
    fi
    
    # Configure Flutter for web and mobile development only
    flutter config --no-enable-linux-desktop
    flutter config --no-enable-macos-desktop
    flutter config --no-enable-windows-desktop
    echo "✓ Flutter configured for web and mobile development"
}

install_flutter

# Run Flutter doctor to check installation
echo "Running Flutter doctor..."
flutter doctor

# Optional: Install Firebase CLI and FlutterFire CLI
install_firebase_tools() {
    if [ "$INSTALL_FLUTTERFIRE" = "true" ]; then
        if [ ! -f /usr/lib/firebase ]; then
            echo "Installing Firebase CLI and FlutterFire CLI..."
            wget -O /usr/lib/firebase https://firebase.tools/bin/linux/latest
            chmod +x /usr/lib/firebase
            chown "$USER:$USER" /usr/lib/firebase
            ln -sf /usr/lib/firebase /usr/sbin/firebase
            # Note: firebase login requires interactive session
            echo "Firebase CLI installed - run 'firebase login' manually"
            dart pub global activate flutterfire_cli
            echo "✓ Firebase tools installed"
        else
            echo "✓ Firebase CLI already installed"
        fi
    else
        echo "Firebase tools installation skipped (set INSTALL_FLUTTERFIRE=true to enable)"
    fi
}

install_firebase_tools

echo "=== Flutter Development Environment Setup Complete ==="