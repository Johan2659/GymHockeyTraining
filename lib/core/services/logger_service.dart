import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class LogEntry {
  final String id;
  final LogLevel level;
  final String message;
  final String? error;
  final String? stackTrace;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final String source;

  LogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.metadata,
    required this.timestamp,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level.name,
        'message': message,
        'error': error,
        'stackTrace': stackTrace,
        'metadata': _sanitizeMetadata(metadata),
        'timestamp': timestamp.toIso8601String(),
        'source': source,
      };

  static LogEntry fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'] as String,
        level: LogLevel.values.firstWhere((e) => e.name == json['level']),
        message: json['message'] as String,
        error: json['error'] as String?,
        stackTrace: json['stackTrace'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        source: json['source'] as String,
      );

  // Remove sensitive data from metadata
  Map<String, dynamic>? _sanitizeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;

    final sanitized = Map<String, dynamic>.from(metadata);

    // List of sensitive keys to remove or redact
    const sensitiveKeys = [
      'password',
      'token',
      'key',
      'secret',
      'auth',
      'credential',
      'session',
      'cookie',
      'apiKey',
      'secureKey',
      'encryptionKey',
      'privateKey',
      'publicKey',
      'keyBytes',
      'cipher',
    ];

    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }

    // Also check for keys that contain sensitive words
    final keysToRedact = <String>[];
    for (final key in sanitized.keys) {
      final lowerKey = key.toLowerCase();
      if (lowerKey.contains('key') ||
          lowerKey.contains('password') ||
          lowerKey.contains('token') ||
          lowerKey.contains('secret') ||
          lowerKey.contains('auth') ||
          lowerKey.contains('credential')) {
        keysToRedact.add(key);
      }
    }

    for (final key in keysToRedact) {
      sanitized[key] = '[REDACTED]';
    }

    return sanitized;
  }
}

class LoggerService {
  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService._();

  LoggerService._();

  late Logger _logger;
  late Box<Map> _logsBox;
  static const String _logsBoxName = 'app_logs';
  static const int _maxLogEntries = 1000; // Rotate after 1000 entries

  Future<void> initialize() async {
    // Initialize Hive box for logs
    _logsBox = await Hive.openBox<Map>(_logsBoxName);

    // Initialize logger with custom output
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: _CustomLogOutput(),
    );

    info('LoggerService initialized', source: 'LoggerService');
  }

  void debug(
    String message, {
    String? source,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(LogLevel.debug, message,
        source: source,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata);
  }

  void info(
    String message, {
    String? source,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(LogLevel.info, message,
        source: source,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata);
  }

  void warning(
    String message, {
    String? source,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(LogLevel.warning, message,
        source: source,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata);
  }

  void error(
    String message, {
    String? source,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    _log(LogLevel.error, message,
        source: source,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata);
  }

  void _log(
    LogLevel level,
    String message, {
    String? source,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final logEntry = LogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      level: level,
      message: message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
      metadata: metadata,
      timestamp: DateTime.now(),
      source: source ?? 'Unknown',
    );

    // Log to console via logger package
    switch (level) {
      case LogLevel.debug:
        _logger.d(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.info:
        _logger.i(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.warning:
        _logger.w(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        _logger.e(message, error: error, stackTrace: stackTrace);
        break;
    }

    // Store in Hive
    _storeLogEntry(logEntry);
  }

  void _storeLogEntry(LogEntry entry) {
    try {
      _logsBox.put(entry.id, entry.toJson());
      _rotateLogsIfNeeded();
    } catch (e) {
      // Fallback - just log to console if Hive fails
      _logger.e('Failed to store log entry: $e');
    }
  }

  void _rotateLogsIfNeeded() {
    if (_logsBox.length > _maxLogEntries) {
      // Remove oldest entries (keep most recent)
      final keys = _logsBox.keys.toList();
      final entriesToRemove = keys.length - _maxLogEntries;

      if (entriesToRemove > 0) {
        // Sort by timestamp and remove oldest
        final entries = _logsBox.values
            .map((json) => LogEntry.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        for (int i = 0; i < entriesToRemove; i++) {
          _logsBox.delete(entries[i].id);
        }
      }
    }
  }

  List<LogEntry> getLogs({
    LogLevel? minLevel,
    DateTime? since,
    String? source,
    int? limit,
  }) {
    try {
      var logs = _logsBox.values
          .map((json) => LogEntry.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Apply filters
      if (minLevel != null) {
        logs = logs.where((log) => log.level.index >= minLevel.index).toList();
      }

      if (since != null) {
        logs = logs.where((log) => log.timestamp.isAfter(since)).toList();
      }

      if (source != null) {
        logs = logs
            .where((log) =>
                log.source.toLowerCase().contains(source.toLowerCase()))
            .toList();
      }

      // Sort by timestamp (newest first)
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply limit
      if (limit != null && logs.length > limit) {
        logs = logs.take(limit).toList();
      }

      return logs;
    } catch (e) {
      _logger.e('Failed to retrieve logs: $e');
      return [];
    }
  }

  Future<void> clearLogs() async {
    try {
      await _logsBox.clear();
      info('Logs cleared', source: 'LoggerService');
    } catch (e) {
      _logger.e('Failed to clear logs: $e');
    }
  }

  Future<void> exportLogs() async {
    try {
      final logs = getLogs();

      if (logs.isEmpty) {
        warning('No logs to export', source: 'LoggerService');
        return;
      }

      // Create JSON export
      final exportData = {
        'exported_at': DateTime.now().toIso8601String(),
        'app_version': '1.0.0', // TODO: Get from package info
        'total_logs': logs.length,
        'logs': logs.map((log) => log.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final fileName =
          'hockey_gym_logs_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);

      // Share the file (simplified for now)
      await Share.share(
        'Hockey Gym App Logs exported to: ${file.path}',
        subject: 'App Logs - ${DateTime.now().toString()}',
      );

      info('Logs exported successfully', source: 'LoggerService', metadata: {
        'file_path': file.path,
        'log_count': logs.length,
      });
    } catch (e, stackTrace) {
      error('Failed to export logs',
          source: 'LoggerService', error: e, stackTrace: stackTrace);
    }
  }

  int get logCount => _logsBox.length;

  Map<LogLevel, int> getLogCountByLevel() {
    final counts = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      counts[level] = 0;
    }

    try {
      for (final json in _logsBox.values) {
        final entry = LogEntry.fromJson(Map<String, dynamic>.from(json));
        counts[entry.level] = (counts[entry.level] ?? 0) + 1;
      }
    } catch (e) {
      _logger.e('Failed to count logs by level: $e');
    }

    return counts;
  }

  Future<void> dispose() async {
    try {
      await _logsBox.close();
    } catch (e) {
      _logger.e('Failed to close logs box: $e');
    }
  }
}

class _CustomLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // Output to console (default behavior)
    for (final line in event.lines) {
      print(line);
    }
  }
}

// Extension for easy access to logger
extension LoggerExtension on Object {
  void logDebug(String message, {Map<String, dynamic>? metadata}) {
    LoggerService.instance
        .debug(message, source: runtimeType.toString(), metadata: metadata);
  }

  void logInfo(String message, {Map<String, dynamic>? metadata}) {
    LoggerService.instance
        .info(message, source: runtimeType.toString(), metadata: metadata);
  }

  void logWarning(String message,
      {Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    LoggerService.instance.warning(message,
        source: runtimeType.toString(),
        error: error,
        stackTrace: stackTrace,
        metadata: metadata);
  }

  void logError(String message,
      {Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    LoggerService.instance.error(message,
        source: runtimeType.toString(),
        error: error,
        stackTrace: stackTrace,
        metadata: metadata);
  }
}
