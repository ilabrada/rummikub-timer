# Rummikub Timer

> [!IMPORTANT]
> ## Active Repository Notice
> This is the **new and only active repository** for the Rummikub Timer project.
> The previous repository in **Azure** is **discontinued** and should no longer be used.
> Please use this GitHub repository for all current and future development.

Android app for managing Rummikub turns with multiple players and a configurable turn duration.

## Overview

Rummikub Timer helps players keep track of turns in a Rummikub game.
You can configure how long each turn lasts, add multiple players, and rotate turns automatically once time is up.

## Features

- Multiple player support
- Configurable turn duration
- Automatic player turn rotation
- Clear timer display for active turns
- Built with Flutter (Android-focused usage)

## Tech Stack

- Flutter
- Dart

## Getting Started

### Prerequisites

- Flutter SDK installed
- Android Studio (or VS Code + Android tooling)
- Android emulator or physical Android device

### Installation

1. Clone this repository.
2. Install dependencies:

```bash
flutter pub get
```

3. Run the app on Android:

```bash
flutter run
```

## Development Notes

- Main entry point: `lib/main.dart`
- Flutter configuration: `pubspec.yaml`

## Developer Quickstart (macOS + Android Emulator)

This project is a Flutter app targeting Android.

Run these commands in order.

### One-time setup

```bash
brew install --cask flutter
brew install openjdk@17 android-platform-tools
brew install --cask android-commandlinetools

export PATH="/opt/homebrew/opt/openjdk@17/bin:/opt/homebrew/bin:$PATH"
export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
export ANDROID_SDK_ROOT="/opt/homebrew/share/android-commandlinetools"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

flutter config --android-sdk /opt/homebrew/share/android-commandlinetools

sdkmanager --sdk_root="$ANDROID_SDK_ROOT" \
	"platform-tools" \
	"platforms;android-36" \
	"build-tools;36.0.0" \
	"build-tools;28.0.3" \
	"emulator" \
	"system-images;android-36;google_apis;arm64-v8a"

yes | sdkmanager --sdk_root="$ANDROID_SDK_ROOT" --licenses
flutter doctor -v
```

### Create emulator (first time only)

```bash
export ANDROID_SDK_ROOT="/opt/homebrew/share/android-commandlinetools"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

yes "no" | avdmanager create avd \
	-n Pixel_8_API_36 \
	-k "system-images;android-36;google_apis;arm64-v8a" \
	-d pixel_8
```

### Start emulator + run app

```bash
export PATH="/opt/homebrew/opt/openjdk@17/bin:/opt/homebrew/bin:$PATH"
export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
export ANDROID_SDK_ROOT="/opt/homebrew/share/android-commandlinetools"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

emulator -avd Pixel_8_API_36
adb kill-server
adb start-server
adb devices -l

cd /Users/ivan/Documents/repository/rummikub-timer
flutter pub get
flutter run -d emulator-5554 --device-timeout 90
```

### While app is running

- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Relaunch after closing app

```bash
export PATH="/opt/homebrew/opt/openjdk@17/bin:/opt/homebrew/bin:$PATH"
export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
export ANDROID_SDK_ROOT="/opt/homebrew/share/android-commandlinetools"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

cd /Users/ivan/Documents/repository/rummikub-timer
flutter run -d emulator-5554 --device-timeout 90
```

### If NDK error appears (source.properties missing)

```bash
rm -rf /opt/homebrew/share/android-commandlinetools/ndk/27.0.12077973
cd /Users/ivan/Documents/repository/rummikub-timer
flutter build apk --debug
```

## Release Builds

### Prerequisites (one time)

A signing keystore is required. If you haven't created one yet:

```bash
keytool -genkeypair -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

Then create `android/key.properties` (this file is gitignored and must never be committed):

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=/Users/<you>/upload-keystore.jks
```

### Build App Bundle (Play Store)

Required format for Google Play uploads.

```bash
flutter build appbundle
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Upload this file in Google Play Console when creating or updating a release.

### Build Release APK (direct distribution / sideloading)

Use this to share the app without the Play Store (via link, USB, etc.).

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/rummikub-timer-release.apk`

To install directly on a connected device:

```bash
adb install build/app/outputs/flutter-apk/rummikub-timer-release.apk
```

Recipients installing the APK manually must enable **Install unknown apps** on their device for the app or browser they use to open the file.

### Releasing a new version

1. Bump the version in `pubspec.yaml` — the number after `+` must always increase:
   ```yaml
   version: 1.0.1+6
   ```
2. Build the `.aab` or `.apk` as above.
3. Upload to Play Console or redistribute the new APK.

## Project Status

Active development continues in this GitHub repository.
