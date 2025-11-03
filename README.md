# Flutter Video Demo (Agora + Riverpod)

A near–store-ready Flutter app:
- Login (mocked via ReqRes)
- One-to-one video calling (Agora)
- Users list from REST with offline cache
- Splash screen + app icon
- Riverpod state management
- Android screen share
- Store-ready configs (permissions, signing, versioning)

## Prerequisites
- Flutter (stable)
- Android Studio and/or Xcode
- Agora **App ID** (and temp token if your project uses App Certificate)

## Setup
1. Place images:
    - `assets/icons/video-call.png`
    - `assets/splash/video-call.png`

2. Configure env in `lib/env.dart`:

3. Install deps & generate icons/splash:

flutter pub get
flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons:main

Login

Use ReqRes mock:

Email: eve.holt@reqres.in

Password: cityslicka

Video Call

Enter a Channel ID (e.g., demo-channel-001)

Launch on two devices/emulators and join the same channel

Use toolbar to mute/unmute, toggle video, switch camera, and (Android) screen share

Android Signing

See android/key.properties and android/app/build.gradle instructions in the repo.

Builds

Android APK (release): flutter build apk --release

Android AAB: flutter build appbundle --release

iOS Archive via Xcode.


---

# Lifecycle best practices 

- Implemented `WidgetsBindingObserver` to **mute** tracks when the app is **paused** and restore on **resumed** — avoids crashes and makes backgrounding safe.
- The video UI handles **connecting**, **waiting**, and **disconnected** states gracefully.
- Errors surface via **SnackBars** so the app never silently fails.

---


 **store-ready**:
- ✅ Splash & icons generated from `video-call.png` & `splash.png`
- ✅ Versioning in `pubspec.yaml`
- ✅ All required permissions
- ✅ Android/iOS signing paths documented
- ✅ README with build/run steps

<img width="350" height="2424" alt="Screenshot_1" src="https://github.com/user-attachments/assets/a706151c-c728-45f2-aecc-31a86e465368" />

<img width="350" height="2424" alt="Screenshot_2" src="https://github.com/user-attachments/assets/f5166d62-92af-461d-934e-3adcaf4980dd" />

<img width="350" height="2424" alt="Screenshot_4" src="https://github.com/user-attachments/assets/cfe9d955-7f4b-4caa-bc30-8c983e048c69" />

<img width="350" height="2424" alt="Screenshot_3" src="https://github.com/user-attachments/assets/c8667b95-d3dd-4ba6-9b73-d9eaa54349c5" />



