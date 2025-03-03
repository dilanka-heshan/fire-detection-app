# Fire Detection System

A Flutter-based mobile application for IoT fire detection system with real-time monitoring, alerts, and notifications.

## Features

- Real-time camera feed monitoring
- Fire, smoke, and motion detection
- Push notifications for alerts
- User authentication and authorization
- Camera management
- Alert history and acknowledgment
- System arm/disarm functionality

## Tech Stack

- Flutter for cross-platform mobile development
- Firebase for backend services:
  - Authentication
  - Cloud Firestore
  - Cloud Storage
  - Cloud Messaging
  - App Check
- Provider for state management

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Firebase project setup
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/fire_detection_app.git
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase:

   - Create a new Firebase project
   - Add Android/iOS apps to the project
   - Download and place the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Enable required Firebase services (Authentication, Firestore, Storage)

4. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── models/
│   ├── providers/
│   ├── services/
│   └── theme/
├── features/
│   ├── auth/
│   ├── home/
│   ├── feed/
│   ├── emergency/
│   ├── settings/
│   └── navigation/
└── main.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
