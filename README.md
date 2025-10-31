# 🏒 Hockey Gym Training App

A comprehensive Flutter application designed for hockey players to track their training progress, manage workout programs, and monitor performance analytics.

## 🎯 Features

### Core Functionality
- **Program Management**: Start, pause, and stop training programs
- **Progress Tracking**: Real-time tracking of exercises, sessions, and achievements
- **Performance Analytics**: Detailed insights into training progress and statistics
- **User Profiles**: Personalized settings and role-based program recommendations
- **Session Player**: Interactive workout sessions with exercise tracking
- **Hub Dashboard**: Centralized view of active programs and progress

### Security & Data Protection
- **AES Encryption**: All local data is encrypted with secure key management
- **Platform Security**: Android encrypted SharedPreferences and iOS keychain integration
- **Data Persistence**: Robust storage with fallback mechanisms and migration support
- **Privacy First**: All data stored locally, no external data transmission

### Architecture Highlights
- **Clean Architecture**: Well-structured codebase with clear separation of concerns
- **State Management**: Riverpod-based reactive state management
- **Repository Pattern**: Clean abstraction between data sources and business logic
- **Stream-based Updates**: Real-time UI updates through stream providers
- **Dependency Injection**: Proper DI with code generation

## 🏗️ Architecture

```
lib/
├── app/                    # App configuration and DI
├── core/                   # Core utilities and models
│   ├── errors/            # Custom exceptions and failures
│   ├── models/            # Data models and entities
│   ├── persistence/       # Data persistence services
│   ├── repositories/      # Repository interfaces
│   ├── services/         # Core services (logging, etc.)
│   ├── storage/          # Storage implementations
│   └── utils/            # Utility functions
├── data/                  # Data layer implementation
│   ├── datasources/      # Local data sources
│   └── repositories_impl/ # Repository implementations
└── features/              # Feature modules
    ├── application/       # App state and providers
    ├── extras/           # Bonus workouts and challenges
    ├── hub/              # Main dashboard
    ├── programs/         # Training programs
    ├── progress/         # Progress tracking
    ├── profile/          # User profile management
    └── session/          # Workout session player
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Android device/emulator or iOS simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd GymHockeyTraining
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Setup

1. **Enable linting**
   ```bash
   # Uncomment custom_lint in analysis_options.yaml
   flutter packages pub run build_runner build
   ```

2. **Run tests**
   ```bash
   flutter test
   ```

3. **Run integration tests**
   ```bash
   flutter test integration_test/
   ```

## 🧪 Testing

The app includes comprehensive testing:

- **Unit Tests**: Core functionality and business logic
- **Integration Tests**: End-to-end user flows
- **Crash Tests**: Error handling and recovery
- **Repository Tests**: Data persistence and retrieval

Run all tests:
```bash
flutter test
```

## 🔒 Security

- **Data Encryption**: All user data encrypted with AES-256
- **Secure Storage**: Platform-specific secure storage mechanisms
- **Key Management**: Cryptographically secure key generation and storage
- **Privacy**: No external data transmission, all data stored locally

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Features**: Full feature parity across platforms

## 🛠️ Development

### Code Generation
The app uses code generation for:
- Riverpod providers
- JSON serialization
- Repository implementations

Run code generation:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### State Management
Built with Riverpod for:
- Reactive state management
- Dependency injection
- Provider composition
- Stream-based updates

### Data Persistence
- **Hive**: Encrypted local database
- **SharedPreferences**: Fallback storage
- **Migration**: Schema versioning and data migration

## 📊 Performance

- **Startup Time**: Optimized app initialization
- **Memory Usage**: Efficient state management
- **Storage**: Compressed and encrypted data storage
- **UI**: Smooth 60fps animations and transitions

## 🚀 Deployment

### Store Requirements
- [x] Security implementation
- [x] Error handling
- [x] Performance optimization
- [x] Platform compliance
- [ ] App store listings
- [ ] Privacy policy
- [ ] Terms of service

### Release Process
1. Update version in `pubspec.yaml`
2. Run tests: `flutter test`
3. Build release: `flutter build apk --release`
4. Test on physical devices
5. Submit to app stores

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🏒 About Hockey Training

This app is designed specifically for hockey players who want to:
- Track their off-ice training progress
- Follow structured workout programs
- Monitor performance improvements
- Maintain training consistency
- Achieve their hockey goals

Built with ❤️ for the hockey community.
