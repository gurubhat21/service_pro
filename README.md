# Service Pro

A Flutter Android app for tracking **Computer, Laptop, CCTV, Solar & UPS** services with admin/staff roles, customer management, and Google Maps integration.

## Features

### Admin
- 📊 Dashboard with service statistics
- 👥 Staff management (add/remove, assign roles)
- 📋 Customer management with Google Maps location
- 🔧 Service request creation and tracking
- ✅ Approve/reject clear requests from staff
- ⏰ Reminders for scheduled services
- 🔔 Push notifications

### Staff
- 📱 View assigned services
- 🔄 Update service status
- 📤 Request service completion (clear request)
- 📍 View customer locations on map

### Service Types
- 💻 Computer
- 💻 Laptop
- 📹 CCTV
- ☀️ Solar
- 🔋 UPS

## Tech Stack

- **Flutter** (Dart)
- **Firebase Auth** (Google Sign-In)
- **Cloud Firestore** (NoSQL Database)
- **Firebase Cloud Messaging** (Push Notifications)
- **Google Maps** (Location picker & navigation)
- **Provider** (State Management)

## Getting Started

### Prerequisites
- Flutter SDK 3.x+
- Android Studio / VS Code
- Firebase project configured
- Google Maps API key

### Setup

1. Clone the repository
```bash
git clone https://github.com/gurubhat21/Service-Pro.git
cd Service-Pro
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Add Google Maps API Key in `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

5. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root widget with providers
├── config/
│   ├── theme.dart               # Dark/light theme
│   ├── routes.dart              # Named routes
│   └── constants.dart           # Enums & constants
├── models/                      # Data models
├── services/                    # Firebase & location services
├── providers/                   # State management
├── screens/
│   ├── auth/                    # Login & registration
│   ├── admin/                   # Admin screens
│   └── staff/                   # Staff screens
├── widgets/                     # Reusable UI components
└── utils/                       # Helpers & validators
```

## License
MIT
