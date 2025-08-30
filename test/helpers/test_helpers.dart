import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Test helpers for setting up the testing environment
class TestHelpers {
  /// Initialize the test environment with required services
  static Future<void> initializeTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive with in-memory storage for tests
    Hive.init('./test/');
    
    // Open all required boxes
    await Hive.openBox('user_profile');
    await Hive.openBox('app_settings');
    await Hive.openBox('progress_journal');
    
    // Initialize platform channels for testing
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return './test/';
    });
    
    // Mock flutter_secure_storage
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        return null; // No stored keys initially
      }
      if (methodCall.method == 'write') {
        return null; // Success
      }
      if (methodCall.method == 'delete') {
        return null; // Success
      }
      if (methodCall.method == 'deleteAll') {
        return null; // Success
      }
      if (methodCall.method == 'readAll') {
        return <String, String>{}; // Empty storage
      }
      return null;
    });
  }
  
  /// Clean up after tests
  static Future<void> cleanup() async {
    // Close and clear all boxes
    try {
      if (Hive.isBoxOpen('user_profile')) {
        final box = Hive.box('user_profile');
        await box.clear();
        await box.close();
      }
      if (Hive.isBoxOpen('app_settings')) {
        final box = Hive.box('app_settings');
        await box.clear();
        await box.close();
      }
      if (Hive.isBoxOpen('progress_journal')) {
        final box = Hive.box('progress_journal');
        await box.clear();
        await box.close();
      }
    } catch (e) {
      // Ignore cleanup errors in tests
    }
    
    await Hive.deleteFromDisk();
  }
}
