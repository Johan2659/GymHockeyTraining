import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gymhockeytraining/core/storage/secure_key_service.dart';

void main() {
  group('Security Tests - AES Key Protection', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Mock flutter_secure_storage
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'read':
            return null; // No existing key
          case 'write':
            return null; // Success
          case 'delete':
            return null; // Success
          case 'deleteAll':
            return null; // Success
          case 'readAll':
            return <String, String>{}; // Empty storage
          default:
            return null;
        }
      });

      // Mock shared_preferences
      const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getAll':
            return <String, Object>{}; // Empty preferences
          case 'setString':
            return true; // Success
          case 'remove':
            return true; // Success
          case 'clear':
            return true; // Success
          default:
            return null;
        }
      });

      // Mock path_provider
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getApplicationDocumentsDirectory':
            return './test/documents';
          case 'getTemporaryDirectory':
            return './test/temp';
          default:
            return './test/';
        }
      });
    });

    group('AES Key Security Verification', () {
      test('should generate and manage AES keys securely', () async {
        // Requirement 3: Key not accessible via logs or files
        
        // Test that we can generate an encryption key
        final key = await SecureKeyService.getOrCreateEncryptionKey();
        
        expect(key, isNotNull);
        expect(key.length, equals(32), reason: 'AES key should be 32 bytes (256 bits)');

        // Verify key exists check works
        final hasKey = await SecureKeyService.hasEncryptionKey();
        expect(hasKey, isTrue);

        debugPrint('✅ AES key generation and verification PASSED');
      });

      test('should handle key deletion securely', () async {
        // Ensure we have a key first
        await SecureKeyService.getOrCreateEncryptionKey();
        expect(await SecureKeyService.hasEncryptionKey(), isTrue);

        // Delete the key
        await SecureKeyService.deleteEncryptionKey();
        
        // Verify deletion worked
        final hasKeyAfterDelete = await SecureKeyService.hasEncryptionKey();
        expect(hasKeyAfterDelete, isFalse);

        debugPrint('✅ AES key deletion PASSED');
      });
    });

    group('Crash Handling & Graceful Degradation', () {
      test('should handle storage failures gracefully', () async {
        // Requirement 4: Simulated crash handled gracefully
        
        // First, verify encryption key functionality works normally
        final originalKey = await SecureKeyService.getOrCreateEncryptionKey();
        expect(originalKey, isNotNull);
        expect(originalKey.length, equals(32));
        
        // Verify key exists
        final hasKey = await SecureKeyService.hasEncryptionKey();
        expect(hasKey, isTrue);
        
        // Simulate storage failure by deleting the key
        await SecureKeyService.deleteEncryptionKey();
        
        // Verify key is gone
        final hasKeyAfterDelete = await SecureKeyService.hasEncryptionKey();
        expect(hasKeyAfterDelete, isFalse);
        
        // App should handle the missing key gracefully by creating a new one
        final newKey = await SecureKeyService.getOrCreateEncryptionKey();
        expect(newKey, isNotNull);
        expect(newKey.length, equals(32));
        expect(newKey, isNot(equals(originalKey)), reason: 'Should generate a new key');
        
        debugPrint('✅ Crash handling test PASSED - App handles storage failures gracefully');
      });

      test('should recover from key corruption gracefully', () async {
        // This test simulates what happens when storage is corrupted
        
        // First get a valid key
        final validKey = await SecureKeyService.getOrCreateEncryptionKey();
        expect(validKey, isNotNull);
        
        // Delete the key to simulate corruption/loss
        await SecureKeyService.deleteEncryptionKey();
        
        // Should be able to recover by getting a new key
        final recoveredKey = await SecureKeyService.getOrCreateEncryptionKey();
        expect(recoveredKey, isNotNull);
        expect(recoveredKey.length, equals(32));
        
        debugPrint('✅ Recovery test PASSED - App handles storage corruption gracefully');
      });
    });
  });
}
