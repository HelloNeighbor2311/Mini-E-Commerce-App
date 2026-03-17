# mini_commerce_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Firestore Configuration

Project has been prepared to support saving order data to Firestore.

1. Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

2. Login and configure Firebase for this app:

```bash
flutterfire configure
```

3. Replace generated content in `lib/firebase_options.dart` (or overwrite file).

4. Enable Firebase in app config:

Set `AppDataConfig.useFirebase = true` in `lib/config/app_data_config.dart`.

5. Get packages:

```bash
flutter pub get
```

When Firebase is enabled, order data is still saved locally by SharedPreferences
and also synced to Firestore collection: `orders`.
