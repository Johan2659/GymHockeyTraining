import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../logging/logger_config.dart';

/// Local key-value store wrapper for Hive with JSON string storage
/// Provides a clean interface for reading/writing/deleting data by key
class LocalKVStore {
  static final _logger = AppLogger.getLogger();

  /// Reads a JSON string from the specified box by key
  /// Returns null if key doesn't exist or if an error occurs
  static Future<String?> read(String boxName, String key) async {
    try {
      final box = Hive.box(boxName);
      final value = box.get(key);

      if (value == null) {
        return null;
      }

      if (value is String) {
        return value;
      } else {
        _logger.w(
            'LocalKVStore: Value for key "$key" is not a String: ${value.runtimeType}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('LocalKVStore: Failed to read key "$key" from box "$boxName"',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Writes a JSON string to the specified box by key
  /// Returns true if successful, false otherwise
  static Future<bool> write(
      String boxName, String key, String jsonValue) async {
    try {
      // Validate JSON format
      try {
        jsonDecode(jsonValue);
      } catch (e) {
        _logger.e('LocalKVStore: Invalid JSON provided for key "$key"',
            error: e);
        return false;
      }

      final box = Hive.box(boxName);
      await box.put(key, jsonValue);

      return true;
    } catch (e, stackTrace) {
      _logger.e('LocalKVStore: Failed to write key "$key" to box "$boxName"',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Deletes a key from the specified box
  /// Returns true if successful, false otherwise
  static Future<bool> delete(String boxName, String key) async {
    try {
      final box = Hive.box(boxName);
      await box.delete(key);

      return true;
    } catch (e, stackTrace) {
      _logger.e('LocalKVStore: Failed to delete key "$key" from box "$boxName"',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Checks if a key exists in the specified box
  static Future<bool> exists(String boxName, String key) async {
    try {
      final box = Hive.box(boxName);
      final exists = box.containsKey(key);

      return exists;
    } catch (e, stackTrace) {
      _logger.e('LocalKVStore: Failed to check key "$key" in box "$boxName"',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Gets all keys from the specified box
  static Future<List<String>> getKeys(String boxName) async {
    try {
      final box = Hive.box(boxName);
      final keys = box.keys.cast<String>().toList();

      return keys;
    } catch (e, stackTrace) {
      _logger.e('LocalKVStore: Failed to get keys from box "$boxName"',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Clears all data from the specified box
  /// Use with caution!
  static Future<bool> clear(String boxName) async {
    try {
      _logger.w('LocalKVStore: Clearing all data from box "$boxName"');

      final box = Hive.box(boxName);
      await box.clear();

      _logger.w('LocalKVStore: Successfully cleared box "$boxName"');
      return true;
    } catch (e, stackTrace) {
      _logger.e('LocalKVStore: Failed to clear box "$boxName"',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Gets the number of items in the specified box
  static Future<int> getCount(String boxName) async {
    try {
      final box = Hive.box(boxName);
      return box.length;
    } catch (e, stackTrace) {
      _logger.e('LocalKVStore: Failed to get count from box "$boxName"',
          error: e, stackTrace: stackTrace);
      return 0;
    }
  }

  /// Reads multiple keys at once (bulk read) - more efficient than individual reads
  /// Returns a map of key -> value (null for missing keys)
  static Future<Map<String, String?>> readBulk(
      String boxName, List<String> keys) async {
    try {
      _logger.d(
          'LocalKVStore: Bulk reading ${keys.length} keys from box "$boxName"');

      final box = Hive.box(boxName);
      final results = <String, String?>{};

      for (final key in keys) {
        final value = box.get(key);
        if (value is String) {
          results[key] = value;
        } else {
          results[key] = null;
        }
      }

      final successCount = results.values.where((v) => v != null).length;
      _logger.d(
          'LocalKVStore: Successfully read $successCount/${keys.length} keys from box "$boxName"');
      return results;
    } catch (e, stackTrace) {
      _logger.e(
          'LocalKVStore: Failed to bulk read keys from box "$boxName"',
          error: e,
          stackTrace: stackTrace);
      return {};
    }
  }
}
