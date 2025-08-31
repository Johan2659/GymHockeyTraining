# Hockey Gym App - Logging & Error Handling System

## Overview

The Hockey Gym app implements a comprehensive logging and error handling system for production stability. The system captures errors across repositories and state notifiers, stores logs locally in encrypted Hive storage, and provides export functionality.

## Architecture

### LoggerService
- **Location**: `lib/core/services/logger_service.dart`
- **Purpose**: Centralized logging service wrapper around the `logger` package
- **Features**:
  - Local file logging via Hive box
  - Log rotation (max 1000 entries)
  - Sensitive data sanitization
  - Export functionality
  - Multiple log levels (debug, info, warning, error)

### Log Storage
- **Storage**: Encrypted Hive box (`app_logs`)
- **Encryption**: Uses same encryption key as other app data
- **Rotation**: Automatically removes oldest entries when limit exceeded
- **Security**: Sensitive data (passwords, tokens, keys) automatically redacted

### Log Export
- **Access**: Profile Screen → "Export Logs" button
- **Format**: JSON file with timestamp
- **Location**: Device's documents directory
- **Share**: Uses system share functionality
- **Content**: Application logs + progress events

## Usage Examples

### Basic Logging
```dart
// Direct LoggerService usage
LoggerService.instance.info('User logged in', source: 'AuthService');
LoggerService.instance.error('Database connection failed', 
  source: 'DatabaseService', error: e, stackTrace: stackTrace);
```

### Extension Methods
```dart
// Using the convenient extension (automatically uses class name as source)
class MyWidget extends StatelessWidget {
  void someMethod() {
    logInfo('Widget rendered successfully');
    logError('Failed to load data', error: e, stackTrace: stackTrace);
  }
}
```

### Repository Logging
```dart
// In repository implementations
LoggerService.instance.debug('Getting session by ID: $id', 
  source: 'SessionRepositoryImpl');
LoggerService.instance.info('Found session: ${session.title}', 
  source: 'SessionRepositoryImpl', metadata: {'sessionId': id});
```

### State Provider Logging
```dart
// In Riverpod providers
LoggerService.instance.info('Starting program action', 
  source: 'startProgramAction', metadata: {'programId': programId});
```

## Log Levels

1. **Debug**: Detailed diagnostic information
2. **Info**: General information about app flow
3. **Warning**: Potentially harmful situations
4. **Error**: Error events but app can continue

## Security Features

### Sensitive Data Protection
The following keys are automatically redacted from log metadata:
- password, token, key, secret
- auth, credential, session, cookie
- apiKey, secureKey

### Example:
```dart
// Input
LoggerService.instance.info('User authenticated', metadata: {
  'username': 'john_doe',
  'password': 'secret123',  // Will be redacted
  'token': 'abc123'         // Will be redacted
});

// Stored
{
  "metadata": {
    "username": "john_doe",
    "password": "[REDACTED]",
    "token": "[REDACTED]"
  }
}
```

## Integration Points

### Initialization
- Initialized in `main.dart` after Hive setup
- Must be called before other services that use logging

### Repository Integration
- All repository implementations include LoggerService logging
- Errors are logged with full context and stack traces
- Success operations logged at info level

### State Provider Integration
- Action providers include comprehensive logging
- Error states captured with full context
- State changes tracked for debugging

### UI Integration
- Export functionality in Profile Screen
- Error states logged from UI components
- User actions tracked where appropriate

## Log Rotation

- **Trigger**: When log count exceeds 1000 entries
- **Strategy**: Remove oldest entries first
- **Retention**: Keep most recent 1000 entries
- **Performance**: Rotation happens automatically during log writes

## Export Format

```json
{
  "exported_at": "2025-08-31T12:00:00.000Z",
  "app_version": "1.0.0",
  "total_logs": 150,
  "logs": [
    {
      "id": "1693483200000",
      "level": "info",
      "message": "User logged in successfully",
      "source": "AuthService",
      "timestamp": "2025-08-31T12:00:00.000Z",
      "metadata": {
        "userId": "user123"
      }
    }
  ]
}
```

## Production Considerations

1. **Performance**: Async logging doesn't block UI
2. **Storage**: Automatic cleanup prevents unlimited growth
3. **Privacy**: Sensitive data automatically redacted
4. **Debugging**: Rich context for troubleshooting production issues
5. **Export**: Easy data extraction for support purposes

## Dependencies

- `logger: ^2.4.0` - Core logging functionality
- `hive: ^2.2.3` - Local storage
- `share_plus: ^10.0.0` - Export sharing
- `path_provider: ^2.1.4` - File system access

## Future Enhancements

- Remote log shipping (if needed)
- Log filtering in export UI
- Log viewer in Profile Screen
- Performance metrics logging
- Crash reporting integration
