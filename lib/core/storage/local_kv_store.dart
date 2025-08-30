import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

/// Local key-value store wrapper for Hive with JSON string storage
/// Provides a clean interface for reading/writing/deleting data by key
class LocalKVStore {
  static final _logger = Logger();
  
  /// Reads a JSON string from the specified box by key
  /// Returns null if key doesn't exist or if an error occurs
  static Future<String?> read(String boxName, String key) async {
    try {
      _logger.d('LocalKVStore: Reading key "$key" from box "$boxName"');
      
      final box = Hive.box(boxName);
      final value = box.get(key);
      
      if (value == null) {
        _logger.d('LocalKVStore: Key "$key" not found in box "$boxName"');
        return null;
      }
      
      if (value is String) {
        _logger.d('LocalKVStore: Successfully read key "$key" from box "$boxName"');
        return value;
      } else {
        _logger.w('LocalKVStore: Value for key "$key" is not a String: ${value.runtimeType}');
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
  static Future<bool> write(String boxName, String key, String jsonValue) async {
    try {
      _logger.d('LocalKVStore: Writing key "$key" to box "$boxName"');
      
      // Validate JSON format
      try {
        jsonDecode(jsonValue);
      } catch (e) {
        _logger.e('LocalKVStore: Invalid JSON provided for key "$key"', error: e);
        return false;
      }
      
      final box = Hive.box(boxName);
      await box.put(key, jsonValue);
      
      _logger.d('LocalKVStore: Successfully wrote key "$key" to box "$boxName"');
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
      _logger.d('LocalKVStore: Deleting key "$key" from box "$boxName"');
      
      final box = Hive.box(boxName);
      await box.delete(key);
      
      _logger.d('LocalKVStore: Successfully deleted key "$key" from box "$boxName"');
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
      _logger.d('LocalKVStore: Checking if key "$key" exists in box "$boxName"');
      
      final box = Hive.box(boxName);
      final exists = box.containsKey(key);
      
      _logger.d('LocalKVStore: Key "$key" ${exists ? "exists" : "does not exist"} in box "$boxName"');
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
      _logger.d('LocalKVStore: Getting all keys from box "$boxName"');
      
      final box = Hive.box(boxName);
      final keys = box.keys.cast<String>().toList();
      
      _logger.d('LocalKVStore: Found ${keys.length} keys in box "$boxName"');
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
}
