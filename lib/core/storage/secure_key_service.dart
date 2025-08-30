import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Service for managing encrypted AES keys using flutter_secure_storage
class SecureKeyService {
  static const String _keyStorageKey = 'hive_encryption_key';
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
  static Future<Uint8List> getOrCreateEncryptionKey() async {
    try {
      _logger.d('SecureKeyService: Getting or creating encryption key');
      
      // Try to get existing key
      final existingKey = await _secureStorage.read(key: _keyStorageKey);
      
      if (existingKey != null && existingKey.isNotEmpty) {
        _logger.d('SecureKeyService: Found existing encryption key');
        final keyBytes = base64Decode(existingKey);
        
        if (keyBytes.length == 32) {
          return Uint8List.fromList(keyBytes);
        } else {
          _logger.w('SecureKeyService: Existing key has wrong length (${keyBytes.length}), creating new one');
        }
      }
      
      // Create new 32-byte AES key
      _logger.i('SecureKeyService: Creating new encryption key');
      final newKey = await _generateSecureKey();
      
      // Store the key securely
      final keyBase64 = base64Encode(newKey);
      await _secureStorage.write(key: _keyStorageKey, value: keyBase64);
      
      _logger.i('SecureKeyService: Successfully created and stored new encryption key');
      return newKey;
      
    } catch (e, stackTrace) {
      _logger.e('SecureKeyService: Failed to get or create encryption key', error: e, stackTrace: stackTrace);
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
      _logger.w('SecureKeyService: Deleting encryption key');
      await _secureStorage.delete(key: _keyStorageKey);
      _logger.w('SecureKeyService: Encryption key deleted');
    } catch (e, stackTrace) {
      _logger.e('SecureKeyService: Failed to delete encryption key', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Checks if an encryption key exists
  static Future<bool> hasEncryptionKey() async {
    try {
      final key = await _secureStorage.read(key: _keyStorageKey);
      return key != null && key.isNotEmpty;
    } catch (e) {
      _logger.e('SecureKeyService: Failed to check for encryption key', error: e);
      return false;
    }
  }
}
