<p align="center">
  <img src="assets/images/orbitlogo_for_launcher.png" width="128" alt="Orbit app icon">
</p>

<h1 align="center">NTUOrbit</h1>

<p align="center">
  A social and food-discovery app for exchange students at Nanyang Technological University.
</p>

## About Orbit

Orbit helps students settle into life at NTU by making it easier to meet people and
find somewhere to eat on campus. The app is built with Flutter and currently uses
the display name **NTUOrbit** in its native platform projects.

The app's two main experiences are:

- **Find Friends** — create a profile, filter students by characteristics such as
  course, year, hall, country, languages, and interests, then send and manage
  friend requests.
- **Chat** — exchange real-time messages with accepted friends, with unread state
  tracking and push notifications.
- **Food Finder** — browse campus food by category and landmark/canteen, inspect
  stalls and opening hours, browse menus, and vote stalls up or down.

## Screen examples

The repository does not currently contain exported UI screenshots. The following
are the implemented screen flows and their source files:

| Screen | What it demonstrates | Source |
| --- | --- | --- |
| Sign in / sign up | NTU email authentication and account creation | [`lib/screens/user_authentication`](lib/screens/user_authentication) |
| Home | Welcome panel and entry points for Food Finder and Friend Finder | [`lib/screens/home/home.dart`](lib/screens/home/home.dart) |
| Friend Finder | Current profile, friend list, notifications, and filter entry point | [`lib/screens/matching/friend_finder.dart`](lib/screens/matching/friend_finder.dart) |
| Filters and results | Single- and multi-select filters followed by matching profiles | [`lib/screens/matching/filter.dart`](lib/screens/matching/filter.dart), [`filter_results.dart`](lib/screens/matching/filter_results.dart) |
| Chat | Timestamped message bubbles, unread messages, and a message composer | [`lib/screens/chat/chat.dart`](lib/screens/chat/chat.dart) |
| Food Finder | Category → canteen → stall → menu navigation | [`lib/screens/food_finder`](lib/screens/food_finder) |
| Profile and settings | Profile editing, blocked users, and light/dark theme controls | [`lib/screens/profile`](lib/screens/profile), [`lib/screens/settings/settings.dart`](lib/screens/settings/settings.dart) |

The home screen uses bundled NTU imagery for its feature cards:

<p align="center">
  <img src="assets/images/ntu_hive.png" width="286" alt="NTU Hive image used in the app">
  <img src="assets/images/Residential halls.png" width="367" alt="Residential halls image asset">
</p>

## Platform availability

This is **not Android-only in the source tree**:

| Platform | Current status |
| --- | --- |
| **Android** | Primary configured target. Firebase Android configuration, launcher icon, and Android splash screen are included. Minimum SDK is 23. |
| **iOS** | Flutter/iOS project and iOS Firebase options are present. Apple signing, Firebase/APNs setup, and device testing still need to be completed for a release build. |
| **Web** | Not configured for Firebase; the generated options explicitly reject web. |
| **macOS, Windows, Linux** | Flutter runner scaffolding exists, but Firebase options are not configured for these targets. |

The launcher icon is generated from
[`assets/images/orbitlogo_for_launcher.png`](assets/images/orbitlogo_for_launcher.png).
Native splash configuration is currently enabled for Android and disabled for iOS
and web; see [`native_splash.yaml`](native_splash.yaml).

## Backend services

Orbit uses Firebase as its backend:

- **Firebase Authentication** — email/password accounts restricted by the app to
  addresses matching `*@e.ntu.edu.sg`; email verification and password reset are
  supported.
- **Cloud Firestore** — stores user profiles, friend requests, friendships,
  blocked users, chat rooms/messages, and the Food Finder hierarchy. Firestore
  streams provide live chat, friend, notification, and food-directory updates.
- **Cloud Storage** — stores profile images uploaded from the profile editor.
- **Firebase Cloud Messaging (FCM)** — registers device tokens and delivers
  notifications for new messages, friend requests, and accepted requests.
- **Cloud Functions for Firebase** — server-side notification handlers in
  [`functions/index.js`](functions/index.js). They run in `asia-northeast1` and
  use the Admin SDK to read Firestore and send FCM notifications:
  - `sendMessageNotification` listens to
    `chat_rooms/{chatRoomId}/messages/{messageId}`.
  - `sendFriendRequestNotification` listens to
    `users/{userId}/receivedRequests/{requestId}`.
  - `sendAcceptedFriendRequestNotification` listens to
    `users/{userId}/friends/{friendId}`.

The configured Firebase project is `dip-app-c7e68` (see [`.firebaserc`](.firebaserc)).
Although a Realtime Database URL is present in the generated Firebase options,
the application code currently uses **Cloud Firestore**, not the Realtime
Database, for its application data.

### Firestore model

```text
users/{uid}
├── friends/{friendId}
├── sentRequests/{receiverId}
├── receivedRequests/{senderId}
├── blockedUsers/{blockedUid}

chat_rooms/{chatRoomId}
└── messages/{messageId}

categories/{categoryId}
└── canteens/{canteenId}
    └── stalls/{stallId}
        ├── menu/{menuItemId}
        └── votes/{uid}
```

## Technology stack

- Flutter / Dart (SDK constraint: `^3.5.2`)
- Firebase Core, Auth, Firestore, Storage, Messaging
- Firebase Cloud Functions with Node.js 18
- Provider for theme and unread-count state
- `image_picker` for profile photos and `flutter_svg` for food voting icons

## Project structure

```text
lib/
├── components/             Reusable widgets
├── models/                 Message and unread-count models
├── screens/                Authentication and app feature screens
├── services/               Auth, Firestore, chat, and backend integration
└── theme/                  Light and dark themes
functions/                  Firebase Cloud Functions
assets/images/              Orbit branding and in-app imagery
android/, ios/              Native Flutter platform projects
```

## Getting started

### Prerequisites

- Flutter SDK compatible with Dart `^3.5.2`
- Android Studio/Xcode for the platform you want to run
- Node.js 18 and the Firebase CLI if working on Cloud Functions

### Run the Flutter app

```bash
flutter pub get
flutter run
```

New accounts must use an NTU exchange-student email in the format
`name@e.ntu.edu.sg`. Firebase credentials and platform configuration must be
available before the app can authenticate or load data.

### Work with Cloud Functions

```bash
cd functions
npm install
npm run serve      # Run the Functions emulator
npm run deploy     # Deploy functions to Firebase
npm run logs       # View deployed function logs
```

### Validate changes

```bash
flutter analyze
flutter test
```

## Current project status

Orbit is an in-development Flutter application. Android is the most complete
configured target, while iOS has a project scaffold and Dart Firebase options
but still requires Apple-specific release configuration. The repository also
contains generated web and desktop runners, but those targets are not currently
configured as supported deployments.
