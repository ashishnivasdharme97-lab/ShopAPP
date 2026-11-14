# shop_app

Flutter client for the shop API.

## Local API

The default API URL is `http://10.0.2.2:5022/api` for the Android emulator and
`http://localhost:5022/api` for the iOS simulator. For a physical device, pass
the development computer's LAN URL at run time, for example:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5022/api
```

Replace the example address with the computer's current LAN IP. The admin
registration key is entered in the app for the initial setup request and is
not saved.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
