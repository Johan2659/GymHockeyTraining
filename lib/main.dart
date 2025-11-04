import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'core/storage/hive_boxes.dart';
import 'core/storage/migration_service.dart';
import 'core/storage/secure_key_service.dart';
import 'core/persistence/persistence_service.dart';
import 'core/persistence/persistence_debugger.dart';
import 'core/services/logger_service.dart';

/// Global logger instance
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable debug paint borders (green/yellow lines in debug mode)
  debugPaintSizeEnabled = false;

  try {
    logger.i('🏒 Starting Hockey Gym App...');

    // Initialize Hive with encryption
    await _initializeHive();

    // Initialize LoggerService for centralized logging
    await LoggerService.instance.initialize();
    LoggerService.instance
        .info('LoggerService initialized successfully', source: 'main');

    // Initialize persistence service with schema versioning and fallback
    await PersistenceService.initialize();

    // Debug: Check what data exists on startup
    await PersistenceDebugger.debugStoredData();

    // Run migrations
    await MigrationService.ensureMigrations();

    logger.i('✅ App initialization complete');
    LoggerService.instance.info('App initialization complete', source: 'main');

    runApp(
      const ProviderScope(
        child: HockeyGymApp(),
      ),
    );
  } catch (e, stackTrace) {
    logger.f('💥 Failed to initialize app', error: e, stackTrace: stackTrace);
    // Try to log with LoggerService if it's initialized
    try {
      LoggerService.instance.error('App initialization failed',
          source: 'main', error: e, stackTrace: stackTrace);
    } catch (_) {
      // LoggerService not available, continue with regular logger
    }
    rethrow;
  }
}

/// Initializes Hive with encryption and opens all necessary boxes
Future<void> _initializeHive() async {
  try {
    logger.i('🔐 Initializing encrypted Hive storage...');

    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    logger.d('📂 Hive initialized at: ${appDocumentDir.path}');

    // Get or create encryption key
    final encryptionKey = await SecureKeyService.getOrCreateEncryptionKey();
    final cipher = HiveAesCipher(encryptionKey);
    logger.d('🔑 Encryption key ready');

    // Open all encrypted boxes
    logger.i('📦 Opening encrypted Hive boxes...');

    final boxOpenFutures = HiveBoxes.allBoxes.map((boxName) async {
      try {
        await Hive.openBox(
          boxName,
          encryptionCipher: cipher,
        );
        logger.d('✅ Opened box: $boxName');
      } catch (e) {
        logger.e('❌ Failed to open box: $boxName', error: e);
        rethrow;
      }
    });

    // Wait for all boxes to open
    await Future.wait(boxOpenFutures);

    logger.i('🎯 All Hive boxes opened successfully');
  } catch (e, stackTrace) {
    logger.e('💥 Failed to initialize Hive', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
