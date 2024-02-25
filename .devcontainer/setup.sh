#!/bin/bash
# Check for cmdline-tools in Android-SDK
DIR="/usr/lib/android-sdk/cmdline-tools/"
if [ -d $DIR ]
then
    echo "cmdline-tools already installed"
else
    # Set up if $cmdline-tools aren't installed.#
    echo "Installing cmdline-tools in ${DIR}..."
    # Download, create folder structure, and set permissions for Android SDK
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    unzip commandlinetools*.zip
    mv ./cmdline-tools/ ./latest
    mkdir cmdline-tools
    mv latest/ cmdline-tools/
    rm commandlinetools*.zip
    mv cmdline-tools/ /usr/lib/android-sdk/
    chown $USER:$USER /usr/lib/android-sdk/ -R
    ln -s /usr/lib/android-sdk/cmdline-tools/latest/bin/sdkmanager /usr/sbin/sdkmanager
    echo "cmdline-tools installed and sdkmanager symbolically linked to /usr/sbin/sdkmanager" 
fi
# Update/accept licences
yes | sdkmanager --update
yes | sdkmanager --licenses
sdkmanager "platforms;android-29"
# Check for Chrome
if [ -x  "/usr/bin/google-chrome" ]
then
    echo "Chrome already installed"
else
    # Download and install chrome
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    apt install -y ./google-chrome*.deb
    rm google-chrome*.deb
    echo "Chrome installed"
fi

# Check for Flutter
DIR="/usr/lib/flutter/"
if [ -d $DIR ]
then
    echo "Flutter already installed"
else
    # Download and set path/permissions for flutter, then update and verify
    git clone https://github.com/flutter/flutter.git -b stable $DIR
    ln -s /usr/lib/flutter/bin/dart /usr/sbin/dart
    ln -s /usr/lib/flutter/bin/flutter /usr/sbin/flutter
    flutter precache
    chown $USER:$USER /usr/lib/flutter/ -R
    echo "flutter installed and symbolically linked to /usr/sbin/flutter"
fi
flutter config --no-enable-linux-desktop
flutter config --no-enable-macos-desktop
flutter config --no-enable-windows-desktop
echo "flutter configured for web and mobile"
flutter doctor

if [ "$1" = "--install-flutterfire" ]; then
    # Check for Firebase-CLI
    FILE="/usr/lib/firebase"
    if [ -f $FILE ]
    then
        echo "Firebase-CLI already installed"
    else
        # Download and install firebase-cli
        wget -O firebase https://firebase.tools/bin/linux/latest
        mv firebase /usr/lib/
        chmod +x /usr/lib/firebase
        chown $USER:$USER /usr/lib/firebase
        ln -s /usr/lib/firebase /usr/sbin/firebase
        firebase login
        dart pub global activate flutterfire_cli
    fi
fi

chown $USER:$USER /usr/lib/android-sdk/ -R
chown $USER:$USER /workspaces/ -R