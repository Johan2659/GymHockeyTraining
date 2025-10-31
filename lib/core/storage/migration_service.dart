import 'package:logger/logger.dart';
import 'hive_boxes.dart';
import 'local_kv_store.dart';

/// Service for managing database schema migrations
class MigrationService {
  static const String _schemaVersionKey = 'schema_version';
  static const int _currentSchemaVersion = 1;
  static final _logger = Logger();

  /// Ensures all necessary migrations are applied
  /// Call this after opening Hive boxes but before using the database
  static Future<void> ensureMigrations() async {
    try {
      _logger.i('MigrationService: Starting migration check...');

      // Get current schema version from storage
      final currentVersion = await _getCurrentSchemaVersion();
      _logger.i('MigrationService: Current schema version: $currentVersion');
      _logger
          .i('MigrationService: Target schema version: $_currentSchemaVersion');

      if (currentVersion < _currentSchemaVersion) {
        _logger.i(
            'MigrationService: Migrations needed from v$currentVersion to v$_currentSchemaVersion');
        await _runMigrations(currentVersion, _currentSchemaVersion);
      } else {
        _logger.i(
            'MigrationService: Database is up to date, no migrations needed');
      }

      _logger.i('MigrationService: Migration check completed successfully');
    } catch (e, stackTrace) {
      _logger.e('MigrationService: Failed during migration process',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Gets the current schema version from storage
  /// Returns 0 if no version is stored (first run)
  static Future<int> _getCurrentSchemaVersion() async {
    try {
      final versionString =
          await LocalKVStore.read(HiveBoxes.migrations, _schemaVersionKey);

      if (versionString == null) {
        _logger.d(
            'MigrationService: No schema version found, assuming first run (v0)');
        return 0;
      }

      // Parse JSON to get version number
      final versionData = {'version': int.tryParse(versionString) ?? 0};
      return versionData['version']!;
    } catch (e) {
      _logger.w('MigrationService: Failed to read schema version, assuming v0',
          error: e);
      return 0;
    }
  }

  /// Runs all necessary migrations from startVersion to endVersion
  static Future<void> _runMigrations(int startVersion, int endVersion) async {
    try {
      _logger.i(
          'MigrationService: Running migrations from v$startVersion to v$endVersion');

      for (int version = startVersion + 1; version <= endVersion; version++) {
        _logger.i('MigrationService: Applying migration to v$version');
        await _applyMigration(version);
        await _setSchemaVersion(version);
        _logger
            .i('MigrationService: Successfully applied migration to v$version');
      }

      _logger.i('MigrationService: All migrations completed successfully');
    } catch (e, stackTrace) {
      _logger.e('MigrationService: Migration failed',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Applies a specific migration version
  static Future<void> _applyMigration(int version) async {
    switch (version) {
      case 1:
        await _migrateToV1();
        break;

      // Future migrations will be added here:
      // case 2:
      //   await _migrateToV2();
      //   break;

      default:
        _logger
            .w('MigrationService: No migration defined for version $version');
    }
  }

  /// Migration to version 1: Initial setup (no-op)
  /// This is the first version, so no actual migration is needed
  static Future<void> _migrateToV1() async {
    _logger.i('MigrationService: Applying v1 migration - Initial setup');

    // V1 is the initial version with our domain models
    // No migration needed, just log that we're setting up the initial schema
    _logger.i(
        'MigrationService: V1 migration complete - Initial schema established');
  }

  /// Sets the schema version in storage
  static Future<void> _setSchemaVersion(int version) async {
    try {
      final success = await LocalKVStore.write(
          HiveBoxes.migrations, _schemaVersionKey, version.toString());

      if (!success) {
        throw Exception('Failed to write schema version $version');
      }

      _logger.d('MigrationService: Set schema version to $version');
    } catch (e, stackTrace) {
      _logger.e('MigrationService: Failed to set schema version to $version',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Gets the current schema version (public method for debugging)
  static Future<int> getCurrentVersion() async {
    return await _getCurrentSchemaVersion();
  }

  /// Forces a migration to a specific version (for testing/debugging)
  /// Use with extreme caution!
  static Future<void> forceMigrationTo(int targetVersion) async {
    try {
      _logger
          .w('MigrationService: FORCING migration to version $targetVersion');

      final currentVersion = await _getCurrentSchemaVersion();
      if (targetVersion > currentVersion) {
        await _runMigrations(currentVersion, targetVersion);
      } else {
        _logger.w(
            'MigrationService: Target version $targetVersion is not greater than current $currentVersion');
      }
    } catch (e, stackTrace) {
      _logger.e(
          'MigrationService: Failed to force migration to version $targetVersion',
          error: e,
          stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Resets the migration state (for testing/debugging)
  /// Use with extreme caution!
  static Future<void> resetMigrations() async {
    try {
      _logger.w('MigrationService: RESETTING migration state');

      final success =
          await LocalKVStore.delete(HiveBoxes.migrations, _schemaVersionKey);

      if (success) {
        _logger.w('MigrationService: Migration state reset to v0');
      } else {
        _logger.e('MigrationService: Failed to reset migration state');
      }
    } catch (e, stackTrace) {
      _logger.e('MigrationService: Failed to reset migrations',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
