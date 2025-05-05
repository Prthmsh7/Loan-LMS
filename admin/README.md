# LoanBee Admin

Admin portal for the LoanBee loan service application. This app is designed to be a separate APK from the user-facing app, with admin-only functionality.

## Features

- Admin-only login with secure authentication
- Dashboard with loan statistics and key metrics
- User management and KYC verification
- Loan approval and rejection
- View and manage all loans in the system
- Administrator settings

## Getting Started

### Prerequisites

- Flutter 3.0 or higher
- Firebase project setup with authentication and Firestore
- Development environment set up for Flutter

### Installation

1. Clone the repository
2. Navigate to the admin directory
3. Run `flutter pub get` to install dependencies

```bash
cd admin
flutter pub get
```

### Configuration

1. Connect the app to your Firebase project:
   - Add the `google-services.json` file to `android/app/`
   - Add the `GoogleService-Info.plist` file to `ios/Runner/`

2. Create an admin icon:
   - Add an admin icon image to `assets/icons/admin_icon.png`
   - Run `flutter pub run flutter_launcher_icons` to generate app icons

### Building the App

#### Android

```bash
flutter build apk --release
```

The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`

#### iOS

```bash
flutter build ios --release
```

Then use Xcode to archive and distribute the app.

## Architecture

The app follows the GetX pattern with:
- Models: Data models representing application entities
- Services: Business logic and Firebase communication
- Controllers: State management for UI
- Views: UI components

## Separate from User App

This admin app is designed to be completely separate from the user-facing app, with:
- Different package name/bundle ID
- Different app icon and branding
- Admin-only authentication
- Specialized admin features and UI

## Security

- Admin users are verified through Firebase authentication
- Only users with the `isAdmin` flag set to true can access this app
- All admin actions are logged for audit purposes
