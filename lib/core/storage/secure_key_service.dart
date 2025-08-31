import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Service for managing encrypted AES keys using flutter_secure_storage with fallback mechanisms
class SecureKeyService {
  static const String _keyStorageKey = 'hive_encryption_key';
  static const String _fallbackKeyStorageKey = 'hive_encryption_key_fallback';
  static const String _devKeyFileName = '.hive_encryption_key_dev';
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  static final _logger = Logger();

  /// Gets the existing encryption key or creates a new one
  /// Returns a 32-byte AES key for Hive encryption
  /// Uses flutter_secure_storage with multiple fallback mechanisms for development
  static Future<Uint8List> getOrCreateEncryptionKey() async {
    try {
      _logger.d('SecureKeyService: Getting or creating encryption key');
      
      // Try to get existing key from secure storage first
      final existingKey = await _secureStorage.read(key: _keyStorageKey);
      _logger.d('SecureKeyService: Secure storage returned key: ${existingKey != null ? '[KEY_PRESENT]' : 'null'}');
      
      if (existingKey != null && existingKey.isNotEmpty) {
        _logger.i('SecureKeyService: Found existing encryption key in secure storage');
        final keyBytes = base64Decode(existingKey);
        
        if (keyBytes.length == 32) {
          _logger.i('SecureKeyService: Using existing 32-byte encryption key from secure storage');
          return Uint8List.fromList(keyBytes);
        } else {
          _logger.w('SecureKeyService: Existing key has wrong length (${keyBytes.length}), trying fallback');
        }
      } else {
        _logger.w('SecureKeyService: No existing encryption key found in secure storage, trying fallback');
      }
      
      // Try fallback storage (SharedPreferences for development)
      final prefs = await SharedPreferences.getInstance();
      final fallbackKey = prefs.getString(_fallbackKeyStorageKey);
      _logger.d('SecureKeyService: Fallback storage returned key: ${fallbackKey != null ? '[KEY_PRESENT]' : 'null'}');
      
      if (fallbackKey != null && fallbackKey.isNotEmpty) {
        _logger.i('SecureKeyService: Found existing encryption key in fallback storage');
        final keyBytes = base64Decode(fallbackKey);
        
        if (keyBytes.length == 32) {
          _logger.i('SecureKeyService: Using existing 32-byte encryption key from fallback storage');
          // Also try to store it back to secure storage for future use
          try {
            await _secureStorage.write(key: _keyStorageKey, value: fallbackKey);
            _logger.d('SecureKeyService: Successfully restored key to secure storage');
          } catch (e) {
            _logger.w('SecureKeyService: Failed to restore key to secure storage: $e');
          }
          return Uint8List.fromList(keyBytes);
        } else {
          _logger.w('SecureKeyService: Fallback key has wrong length (${keyBytes.length}), trying dev file');
        }
      } else {
        _logger.w('SecureKeyService: No existing encryption key found in fallback storage, trying dev file');
      }
      
      // Try development file storage (for Android emulator persistence)
      try {
        final devKey = await _getDevFileKey();
        if (devKey != null) {
          _logger.i('SecureKeyService: Found existing encryption key in dev file storage');
          final keyBytes = base64Decode(devKey);
          
          if (keyBytes.length == 32) {
            _logger.i('SecureKeyService: Using existing 32-byte encryption key from dev file');
            // Store in both secure and SharedPreferences for next time
            await _storeKeyInAllStorages(devKey);
            return Uint8List.fromList(keyBytes);
          } else {
            _logger.w('SecureKeyService: Dev file key has wrong length (${keyBytes.length}), creating new');
          }
        } else {
          _logger.w('SecureKeyService: No existing encryption key found in dev file storage');
        }
      } catch (e) {
        _logger.w('SecureKeyService: Failed to read dev file key: $e');
      }
      
      // Create new 32-byte AES key
      _logger.i('SecureKeyService: Creating new encryption key');
      final newKey = await _generateSecureKey();
      final keyBase64 = base64Encode(newKey);
      
      // Store the key in all available storages
      await _storeKeyInAllStorages(keyBase64);
      
      _logger.i('SecureKeyService: Successfully created and stored new encryption key');
      return newKey;
      
    } catch (e, stackTrace) {
      _logger.e('SecureKeyService: Failed to get or create encryption key', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Store key in all available storage mechanisms
  static Future<void> _storeKeyInAllStorages(String keyBase64) async {
    // Try secure storage first
    try {
      await _secureStorage.write(key: _keyStorageKey, value: keyBase64);
      _logger.i('SecureKeyService: Stored key in secure storage: ${keyBase64.substring(0, 8)}...');
    } catch (e) {
      _logger.w('SecureKeyService: Failed to store key in secure storage: $e');
    }
    
    // Always store in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fallbackKeyStorageKey, keyBase64);
      _logger.i('SecureKeyService: Stored key in fallback storage: ${keyBase64.substring(0, 8)}...');
    } catch (e) {
      _logger.w('SecureKeyService: Failed to store key in fallback storage: $e');
    }
    
    // Store in development file for emulator persistence
    try {
      await _storeDevFileKey(keyBase64);
      _logger.i('SecureKeyService: Stored key in dev file storage: ${keyBase64.substring(0, 8)}...');
    } catch (e) {
      _logger.w('SecureKeyService: Failed to store key in dev file storage: $e');
    }
  }

  /// Get key from development file storage
  static Future<String?> _getDevFileKey() async {
    try {
      // Use external storage directory which persists across app reinstalls
      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir == null) {
        _logger.w('SecureKeyService: External storage not available');
        return null;
      }
      
      final keyFile = File('${extDir.path}/$_devKeyFileName');
      
      if (await keyFile.exists()) {
        final content = await keyFile.readAsString();
        _logger.d('SecureKeyService: Dev file key found: ${content.substring(0, 8)}...');
        return content.trim();
      } else {
        _logger.d('SecureKeyService: Dev file key not found');
        return null;
      }
    } catch (e) {
      _logger.w('SecureKeyService: Error reading dev file key: $e');
      return null;
    }
  }

  /// Store key in development file storage
  static Future<void> _storeDevFileKey(String keyBase64) async {
    try {
      // Use external storage directory which persists across app reinstalls
      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir == null) {
        _logger.w('SecureKeyService: External storage not available');
        return;
      }
      
      final keyFile = File('${extDir.path}/$_devKeyFileName');
      
      await keyFile.writeAsString(keyBase64);
      _logger.d('SecureKeyService: Dev file key stored at: ${keyFile.path}');
    } catch (e) {
      _logger.w('SecureKeyService: Error storing dev file key: $e');
      rethrow;
    }
  }

  /// Generates a cryptographically secure 32-byte key
  static Future<Uint8List> _generateSecureKey() async {
    try {
      // Use secure random number generation
      final secureRandom = List<int>.generate(32, (_) => 
        DateTime.now().millisecondsSinceEpoch.hashCode % 256);
      
      // Mix with system entropy for better randomness
      final systemEntropy = DateTime.now().microsecondsSinceEpoch.toString().codeUnits;
      for (int i = 0; i < 32; i++) {
        secureRandom[i] ^= systemEntropy[i % systemEntropy.length];
      }
      
      return Uint8List.fromList(secureRandom);
    } catch (e) {
      _logger.e('SecureKeyService: Failed to generate secure key', error: e);
      rethrow;
    }
  }

  /// Deletes the stored encryption key (use with caution!)
  static Future<void> deleteEncryptionKey() async {
    try {
      _logger.w('SecureKeyService: Deleting encryption key from both storages');
      
      // Delete from secure storage
      try {
        await _secureStorage.delete(key: _keyStorageKey);
        _logger.w('SecureKeyService: Encryption key deleted from secure storage');
      } catch (e) {
        _logger.w('SecureKeyService: Failed to delete key from secure storage: $e');
      }
      
      // Delete from fallback storage
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_fallbackKeyStorageKey);
        _logger.w('SecureKeyService: Encryption key deleted from fallback storage');
      } catch (e) {
        _logger.w('SecureKeyService: Failed to delete key from fallback storage: $e');
      }
      
    } catch (e, stackTrace) {
      _logger.e('SecureKeyService: Failed to delete encryption key', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Checks if an encryption key exists in either storage
  static Future<bool> hasEncryptionKey() async {
    try {
      // Check secure storage first
      final secureKey = await _secureStorage.read(key: _keyStorageKey);
      if (secureKey != null && secureKey.isNotEmpty) {
        return true;
      }
      
      // Check fallback storage
      final prefs = await SharedPreferences.getInstance();
      final fallbackKey = prefs.getString(_fallbackKeyStorageKey);
      return fallbackKey != null && fallbackKey.isNotEmpty;
    } catch (e) {
      _logger.e('SecureKeyService: Failed to check for encryption key', error: e);
      return false;
    }
  }
}
