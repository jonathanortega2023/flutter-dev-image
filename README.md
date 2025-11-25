# Flutter Development Docker Images

Multi-stage Docker images for Flutter development with different platform configurations.

## Available Images

All images are based on Debian Bookworm Slim and include the Flutter SDK (stable channel).

### Variants

| Image Tag | Platforms | FlutterFire CLI | Use Case |
|-----------|-----------|-----------------|----------|
| `web` | Web only | No | Lightweight web development |
| `web_fire` | Web only | Yes | Web development with Firebase |
| `android` | Android only | No | Android app development |
| `android_fire` | Android only | Yes | Android development with Firebase |

### Image Features

**Base Configuration (all variants):**
- Debian Bookworm Slim
- Flutter SDK (stable channel)
- Non-root user (`vscode`, UID 1000)
- Common build tools (clang, cmake, ninja, pkg-config)
- Git, curl, wget, and essential utilities

**Web Variants (`web`, `web_fire`):**
- Google Chrome (for web testing)
- Web platform enabled

**Android Variants (`android`, `android_fire`):**
- Android SDK with command-line tools
- Latest Android platform and build tools (35.0.0)
- Platform tools (adb, fastboot, etc.)
- Android platform enabled

**FlutterFire Variants (`web_fire`, `android_fire`):**
- Firebase CLI
- FlutterFire CLI (Dart global package)

## Building Images

Use the provided build script to build all variants:

```bash
./build-multistage.sh
```

This script will:
1. Build all 4 image variants
2. Tag them appropriately
3. Push them to Docker Hub

### Manual Build

To build a specific variant manually:

```bash
# Web without FlutterFire
docker build --target web --build-arg FLUTTERFIRE=false -t flutter_dev:web -f Dockerfile.multistage .

# Android with FlutterFire
docker build --target android --build-arg FLUTTERFIRE=true -t flutter_dev:android_fire -f Dockerfile.multistage .
```

## Usage

### Pull from Docker Hub

```bash
docker pull jonathanortega2023/flutter_dev:web
docker pull jonathanortega2023/flutter_dev:web_fire
docker pull jonathanortega2023/flutter_dev:android
docker pull jonathanortega2023/flutter_dev:android_fire
```

### Run Container

```bash
# Web development
docker run -it --rm -v $(pwd):/workspace jonathanortega2023/flutter_dev:web

# Android development
docker run -it --rm -v $(pwd):/workspace jonathanortega2023/flutter_dev:android
```

### Use with VS Code DevContainers

Add to your `.devcontainer/devcontainer.json`:

```json
{
  "name": "Flutter Dev",
  "image": "jonathanortega2023/flutter_dev:web",
  "customizations": {
    "vscode": {
      "extensions": [
        "Dart-Code.flutter",
        "Dart-Code.dart-code"
      ]
    }
  }
}
```

## Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `USER` | `vscode` | Non-root username |
| `USER_UID` | `1000` | User ID |
| `USER_GID` | `$USER_UID` | Group ID |
| `FLUTTER_DIR` | `/usr/lib/flutter` | Flutter SDK installation path |
| `FIREBASE_DIR` | `/usr/lib/firebase` | Firebase CLI installation path |
| `FLUTTERFIRE` | `false` | Install Firebase/FlutterFire CLIs |
| `ANDROID_CLI_TOOLS_URL` | (see Dockerfile) | Android command-line tools download URL |

## Multi-Stage Architecture

The Dockerfile uses a multi-stage build approach:

1. **`base` stage**: Common dependencies, Flutter SDK, and optional Firebase/FlutterFire setup
2. **`web` stage**: Extends base with Chrome and web platform configuration
3. **`android` stage**: Extends base with Android SDK and platform configuration


## Environment Variables

All images set the following environment variables:

```bash
FLUTTER_DIR=/usr/lib/flutter
FIREBASE_DIR=/usr/lib/firebase
ANDROID_SDK_DIR=/usr/lib/android-sdk  # Android only
PATH includes Flutter, Android SDK, and Firebase CLIs
```

## License

Ensure you comply with the licenses of all included software:
- Flutter SDK: BSD 3-Clause
- Android SDK: Android Software Development Kit License
- Firebase CLI: Varies by component
- Google Chrome: Google Chrome Terms of Service