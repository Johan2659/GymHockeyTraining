/// Persistence service providing schema versioning and fallback mechanisms
/// Enhances existing architecture without replacing it
library;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/local_kv_store.dart';
import '../storage/hive_boxes.dart';

/// Service that provides enhanced persistence with schema versioning and fallback
/// Integrates seamlessly with existing LocalKVStore and repository pattern
class PersistenceService {
  static final _logger = Logger();
  static const int _currentSchemaVersion = 1;
  static const String _schemaVersionKey = 'persistence_schema_version';

  static bool _initialized = false;
  static SharedPreferences? _sharedPrefs;

  /// Initialize the persistence service
  /// Call this during app startup after Hive initialization
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      _logger.i(
          'PersistenceService: Initializing schema versioning and fallback...');

      // Initialize SharedPreferences for fallback (skip in tests)
      try {
        _sharedPrefs = await SharedPreferences.getInstance();
      } catch (e) {
        _logger.w(
            'PersistenceService: SharedPreferences not available (test environment?), continuing with Hive only');
        _sharedPrefs = null;
      }

      // Check and run migrations if needed
      await _checkAndRunMigrations();

      _initialized = true;
      _logger.i('PersistenceService: Successfully initialized');
    } catch (e, stackTrace) {
      _logger.e('PersistenceService: Failed to initialize',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Enhanced read with SharedPreferences fallback
  /// First tries Hive via LocalKVStore, then falls back to SharedPreferences
  static Future<String?> readWithFallback(String boxName, String key) async {
    try {
      // Try Hive first via existing LocalKVStore
      final hiveValue = await LocalKVStore.read(boxName, key);
      if (hiveValue != null) {
        return hiveValue;
      }

      // Fallback to SharedPreferences if available
      if (_sharedPrefs != null) {
        final fallbackKey = '${boxName}_$key';
        final fallbackValue = _sharedPrefs!.getString(fallbackKey);

        if (fallbackValue != null) {
          _logger.w(
              'PersistenceService: Using SharedPreferences fallback for $boxName/$key');
          return fallbackValue;
        }
      }

      return null;
    } catch (e) {
      _logger.w('PersistenceService: Read failed for $boxName/$key', error: e);

      // Try fallback even if Hive threw an exception
      if (_sharedPrefs != null) {
        try {
          final fallbackKey = '${boxName}_$key';
          final fallbackValue = _sharedPrefs!.getString(fallbackKey);
          if (fallbackValue != null) {
            _logger.w(
                'PersistenceService: Emergency fallback successful for $boxName/$key');
            return fallbackValue;
          }
        } catch (fallbackError) {
          _logger.e(
              'PersistenceService: Both Hive and SharedPreferences failed for $boxName/$key',
              error: fallbackError);
        }
      }

      return null;
    }
  }

  /// Enhanced write with SharedPreferences backup
  /// Saves to both Hive and SharedPreferences for redundancy
  static Future<bool> writeWithFallback(
      String boxName, String key, String value) async {
    bool hiveSuccess = false;
    bool prefsSuccess = false;

    // Try to save to Hive via existing LocalKVStore
    try {
      hiveSuccess = await LocalKVStore.write(boxName, key, value);
    } catch (e) {
      _logger.w('PersistenceService: Hive write failed for $boxName/$key',
          error: e);
    }

    // Save to SharedPreferences as backup if available
    if (_sharedPrefs != null) {
      try {
        final fallbackKey = '${boxName}_$key';
        prefsSuccess = await _sharedPrefs!.setString(fallbackKey, value);
      } catch (e) {
        _logger.w(
            'PersistenceService: SharedPreferences write failed for $boxName/$key',
            error: e);
      }
    }

    // Success if at least one storage method worked (or SharedPreferences not available)
    final success = hiveSuccess || prefsSuccess;

    if (!success && _sharedPrefs != null) {
      _logger.e(
          'PersistenceService: Both storage methods failed for $boxName/$key');
    } else if (!hiveSuccess && _sharedPrefs != null) {
      _logger.w(
          'PersistenceService: Only SharedPreferences succeeded for $boxName/$key');
    } else if (!prefsSuccess && _sharedPrefs != null) {
      _logger.d(
          'PersistenceService: Hive succeeded, SharedPreferences backup failed for $boxName/$key');
    }

    // In test environment with no SharedPreferences, just return Hive success
    return _sharedPrefs != null ? success : hiveSuccess;
  }

  /// Get current schema version
  static Future<int> getSchemaVersion() async {
    try {
      // Try Hive first
      final hiveVersion =
          await LocalKVStore.read(HiveBoxes.settings, _schemaVersionKey);
      if (hiveVersion != null) {
        return int.tryParse(hiveVersion) ?? 0;
      }

      // Fallback to SharedPreferences if available
      if (_sharedPrefs != null) {
        return _sharedPrefs!.getInt(_schemaVersionKey) ?? 0;
      }

      return 0;
    } catch (e) {
      _logger.w(
          'PersistenceService: Failed to get schema version, defaulting to 0');
      return 0;
    }
  }

  /// Set schema version in both storage systems
  static Future<void> setSchemaVersion(int version) async {
    try {
      // Save to both for redundancy
      await LocalKVStore.write(
          HiveBoxes.settings, _schemaVersionKey, version.toString());

      if (_sharedPrefs != null) {
        await _sharedPrefs!.setInt(_schemaVersionKey, version);
      }

      _logger.d('PersistenceService: Schema version set to $version');
    } catch (e) {
      _logger.w('PersistenceService: Failed to set schema version', error: e);
    }
  }

  /// Check and run migrations if needed
  static Future<void> _checkAndRunMigrations() async {
    final currentVersion = await getSchemaVersion();

    if (currentVersion < _currentSchemaVersion) {
      _logger.i(
          'PersistenceService: Running migrations from v$currentVersion to v$_currentSchemaVersion');

      await _runMigrations(currentVersion, _currentSchemaVersion);
      await setSchemaVersion(_currentSchemaVersion);

      _logger.i('PersistenceService: Migrations completed');
    } else {
      _logger.d('PersistenceService: Schema is up to date (v$currentVersion)');
    }
  }

  /// Run migrations between versions
  static Future<void> _runMigrations(int fromVersion, int toVersion) async {
    for (int version = fromVersion + 1; version <= toVersion; version++) {
      _logger.d('PersistenceService: Running migration to v$version');

      switch (version) {
        case 1:
          await _migrateToV1();
          break;
        // Add future migrations here
        default:
          _logger.w('PersistenceService: Unknown migration version $version');
      }
    }
  }

  /// Migration to version 1
  /// Ensures all existing data is properly backed up to SharedPreferences
  static Future<void> _migrateToV1() async {
    try {
      _logger.d(
          'PersistenceService: Running migration to v1 - backing up existing data');

      // Backup critical data to SharedPreferences
      await _backupCriticalData();

      _logger.d('PersistenceService: v1 migration completed');
    } catch (e, stackTrace) {
      _logger.e('PersistenceService: v1 migration failed',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Backup critical data from Hive to SharedPreferences
  static Future<void> _backupCriticalData() async {
    final criticalKeys = [
      {'box': HiveBoxes.profile, 'key': 'user_profile'},
      {'box': HiveBoxes.settings, 'key': 'program_state'},
    ];

    for (final item in criticalKeys) {
      try {
        final boxName = item['box']!;
        final key = item['key']!;

        final hiveValue = await LocalKVStore.read(boxName, key);
        if (hiveValue != null) {
          final fallbackKey = '${boxName}_$key';
          await _sharedPrefs?.setString(fallbackKey, hiveValue);
          _logger.d('PersistenceService: Backed up $boxName/$key');
        }
      } catch (e) {
        _logger.w(
            'PersistenceService: Failed to backup ${item['box']}/${item['key']}',
            error: e);
      }
    }
  }

  /// Clear data from both Hive and SharedPreferences fallback
  /// This ensures complete data removal when using fallback mechanisms
  static Future<bool> clearWithFallback(String boxName, String key) async {
    try {
      _logger.d(
          'PersistenceService: Clearing $boxName/$key from both storage sources');

      // Clear from Hive
      bool hiveSuccess = false;
      try {
        hiveSuccess = await LocalKVStore.delete(boxName, key);
        _logger.d('PersistenceService: Hive deletion result: $hiveSuccess');
      } catch (e) {
        _logger.w('PersistenceService: Hive deletion failed for $boxName/$key',
            error: e);
      }

      // Clear from SharedPreferences fallback
      bool prefsSuccess = true;
      if (_sharedPrefs != null) {
        try {
          final fallbackKey = '${boxName}_$key';
          prefsSuccess = await _sharedPrefs!.remove(fallbackKey);
          _logger.d(
              'PersistenceService: SharedPreferences deletion result: $prefsSuccess');
        } catch (e) {
          _logger.w(
              'PersistenceService: SharedPreferences deletion failed for $boxName/$key',
              error: e);
          prefsSuccess = false;
        }
      }

      final success = hiveSuccess && prefsSuccess;
      _logger.i(
          'PersistenceService: Complete deletion result: $success (Hive: $hiveSuccess, Prefs: $prefsSuccess)');

      return success;
    } catch (e, stackTrace) {
      _logger.e('PersistenceService: Failed to clear $boxName/$key',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Check if persistence is healthy
  static Future<bool> healthCheck() async {
    try {
      const testKey = 'health_check';
      const testValue = 'test_value';

      // Test write
      final writeSuccess =
          await writeWithFallback(HiveBoxes.settings, testKey, testValue);
      if (!writeSuccess) return false;

      // Test read
      final readValue = await readWithFallback(HiveBoxes.settings, testKey);
      if (readValue != testValue) return false;

      // Clean up
      await LocalKVStore.write(HiveBoxes.settings, testKey, '');

      return true;
    } catch (e) {
      _logger.e('PersistenceService: Health check failed', error: e);
      return false;
    }
  }

  /// Clear all persistence data (useful for testing)
  static Future<void> clearAll() async {
    try {
      _logger.w('PersistenceService: Clearing all data');

      // Clear Hive boxes via LocalKVStore
      await LocalKVStore.clear(HiveBoxes.settings);
      await LocalKVStore.clear(HiveBoxes.profile);
      await LocalKVStore.clear(HiveBoxes.progress);
      await LocalKVStore.clear(HiveBoxes.training);

      // Clear SharedPreferences fallback data if available
      if (_sharedPrefs != null) {
        final keys = _sharedPrefs!.getKeys();
        for (final key in keys) {
          if (key.contains('_')) {
            await _sharedPrefs!.remove(key);
          }
        }
      }

      _logger.i('PersistenceService: All data cleared');
    } catch (e, stackTrace) {
      _logger.e('PersistenceService: Failed to clear data',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Log state change for debugging
  static void logStateChange(String description) {
    if (kDebugMode) {
      _logger.d('PersistenceService: State change - $description');
    }
  }

  /// Reset service for testing (useful in test tearDown)
  static void resetForTesting() {
    _initialized = false;
    _sharedPrefs = null;
  }
}
