import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Production-optimized logger configuration
/// - In DEBUG: Shows all logs including debug and verbose
/// - In RELEASE: Only shows warnings and errors
class AppLogger {
  static Logger getLogger() {
    return Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: kDebugMode ? 2 : 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.none,
      ),
      level: kDebugMode ? Level.debug : Level.warning,
    );
  }
}

/// Custom filter that respects build mode
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) {
      // In debug mode, show all logs
      return true;
    } else {
      // In release mode, only show warnings and errors
      return event.level.index >= Level.warning.index;
    }
  }
}
