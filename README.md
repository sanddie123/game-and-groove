# Game and Groove

A cross-platform Flutter app combining gaming and music, backed by Firebase. Built to run on Android, iOS, web, Windows, macOS, and Linux from a single codebase.

## Features

- **Firebase Authentication** (including Google Sign-In) for user accounts.
- **Cloud Firestore** for storing and syncing app data.
- **Audio playback** via `audioplayers`.
- **YouTube video playback** embedded in-app via `youtube_player_flutter`.
- **Onboarding flow** using `introduction_screen` for first-time users.
- **Multi-platform build targets** — Android, iOS, web, Windows, macOS, and Linux are all pre-configured.

## Tech Stack

- [Flutter](https://flutter.dev) / Dart (SDK `^3.10.7`)
- Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`)
- Google Sign-In
- `audioplayers`, `youtube_player_flutter`, `introduction_screen`, `http`

## Project Structure

```
├── lib/            # Application source (screens, logic)
├── android/        # Android platform project
├── ios/            # iOS platform project
├── web/            # Web platform project
├── windows/        # Windows platform project
├── macos/          # macOS platform project
├── linux/          # Linux platform project
├── firebase.json    # Firebase project configuration
└── pubspec.yaml     # Dependencies and project metadata
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.10.7` or compatible)
- A [Firebase project](https://console.firebase.google.com/) with Authentication and Firestore enabled
- Platform-specific tooling for whichever target you build (Android Studio / Xcode / etc.)

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/sanddie123/game-and-groove.git
   cd game-and-groove
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase**
   This project expects Firebase to be configured for each platform you target (`google-services.json` for Android, `GoogleService-Info.plist` for iOS, and Firebase web config). Use the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) to (re)generate these:
   ```bash
   flutterfire configure
   ```

4. **Enable Google Sign-In**
   Make sure Google Sign-In is enabled as an auth provider in your Firebase console, and that OAuth client IDs are set up for each platform you plan to run on.

5. **Run the app**
   ```bash
   flutter run
   ```
   Or target a specific platform, e.g.:
   ```bash
   flutter run -d chrome     # Web
   flutter run -d windows    # Windows
   ```

## Building for Release

```bash
flutter build apk        # Android
flutter build ios        # iOS
flutter build web         # Web
flutter build windows     # Windows
```

## Notes

- Firebase config files (`google-services.json`, `GoogleService-Info.plist`) contain project-specific keys and are typically excluded from version control — generate your own via `flutterfire configure` rather than reusing someone else's.
