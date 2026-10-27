# Carrom Elite

A real-time multiplayer gaming app built with Flutter, combining a physics-based **Carrom** board game with a **Lottery** game.

![Flutter](https://img.shields.io/badge/Flutter-Dart%203.11-02569B?logo=flutter)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey)

<!-- Add screenshots here, e.g. ![Gameplay](assets/screenshots/gameplay.png) -->

## Features

- **Carrom gameplay:** physics-driven board built with the Flame game engine and Forge2D.
- **Real-time multiplayer:** live game state over WebSockets (Socket.IO).
- **Lottery game:** a second game mode alongside Carrom.
- **Authentication:** OTP-style code entry, with tokens kept in secure storage.
- **Push notifications:** delivered through Firebase Cloud Messaging.
- **Local persistence:** lightweight caching with Hive and shared preferences.
- **Animations:** smooth UI transitions with `flutter_animate`.
- **Cross-platform:** Flutter targets for Android, iOS, web, Windows, macOS and Linux.

## Tech stack

| Area | Package |
| --- | --- |
| Framework | Flutter, Dart `^3.11.4` |
| Game engine and physics | `flame`, `flame_forge2d` |
| State management | `flutter_riverpod` |
| Navigation | `go_router` |
| Networking | `dio` (REST), `socket_io_client` (real-time) |
| Storage | `hive`, `shared_preferences`, `flutter_secure_storage` |
| Notifications | `firebase_messaging` |
| UI | `flutter_animate`, `pinput`, `cupertino_icons` |
| Linting | `flutter_lints` |

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart 3.11.4 or newer
- Android Studio or Xcode for mobile builds
- A Firebase project (for push notifications)
- A running backend that serves the REST API and Socket.IO server

## Getting started

```bash
# 1. Clone the repository
git clone https://github.com/shivanshi-chaurasia/Carrom-Elite.git
cd Carrom-Elite

# 2. Install dependencies
flutter pub get

# 3. Check your setup
flutter doctor

# 4. Run the app
flutter run
```

To run on a specific platform:

```bash
flutter run -d chrome      # web
flutter run -d windows     # desktop (or macos / linux)
flutter run -d <device-id> # connected Android or iOS device
```

### Firebase setup

Push notifications need Firebase configured for each platform you target:

1. Create a project in the [Firebase console](https://console.firebase.google.com/).
2. Add `google-services.json` to `android/app/`.
3. Add `GoogleService-Info.plist` to `ios/Runner/`.

### Backend configuration

The app expects a backend providing REST endpoints and a Socket.IO server. Set the base URLs in your networking config (for example in `lib/`) before running against a real server.

> Update this section with the exact file and variable names used in your project.

## Project structure

```
Carrom-Elite/
├── lib/            Dart source (app code, game logic, UI)
├── assets/
│   └── images/     Logo and images
├── android/        Android platform project
├── ios/            iOS platform project
├── web/            Web platform project
├── windows/        Windows platform project
├── macos/          macOS platform project
├── linux/          Linux platform project
├── test/           Tests
└── pubspec.yaml    Dependencies and asset config
```

The `pubspec.yaml` also declares `assets/icons/` and `assets/animations/` as asset folders, so create them if you add icons or animations.

## Testing

```bash
flutter test
```

## Building for release

```bash
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release        # iOS
flutter build web --release        # Web
```

## Roadmap

- [ ] Add gameplay screenshots
- [ ] Document backend API and socket events
- [ ] Add CI for analysis and tests

## License

Add a license of your choice (for example MIT) and reference it here.
