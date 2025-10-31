import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'package:gymhockeytraining/data/datasources/local_prefs_source.dart';

void main() {
  group('Simple Crash Validation - Requirement 4', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock platform channels
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async => './test/');
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
          .setMockMethodCallHandler((MethodCall methodCall) async => null);
      const MethodChannel('plugins.flutter.io/shared_preferences')
          .setMockMethodCallHandler(
              (MethodCall methodCall) async => <String, Object>{});

      // Initialize Hive
      await Hive.initFlutter();
      await Hive.openBox('user_profile');
    });

    test('✅ Requirement 4: App handles box closure gracefully (no crash)',
        () async {
      print('\n🧪 TESTING: Simulated crash handling...');

      // Step 1: Normal operation
      const profile = Profile(
        role: UserRole.attacker,
        language: 'en',
        units: 'metric',
        theme: 'dark',
      );

      final prefsSource = LocalPrefsSource();
      await prefsSource.saveProfile(profile);
      final normalProfile = await prefsSource.getProfile();
      expect(normalProfile?.role, equals(UserRole.attacker));
      print('✅ Normal operation: Profile saved and loaded successfully');

      // Step 2: SIMULATE CRASH - Close the box
      if (Hive.isBoxOpen('user_profile')) {
        await Hive.box('user_profile').close();
        print('💥 CRASH SIMULATED: user_profile box forcibly closed');
      }

      // Step 3: App should handle gracefully (no exception thrown)
      Profile? profileAfterCrash;
      try {
        profileAfterCrash = await prefsSource.getProfile();
        print('✅ GRACEFUL HANDLING: getProfile() returned without crashing');
      } catch (e) {
        fail('❌ App crashed instead of handling gracefully: $e');
      }

      // Step 4: Should return null instead of crashing
      expect(profileAfterCrash, isNull,
          reason: 'Should return null when storage unavailable, not crash');
      print('✅ SAFE FALLBACK: Returned null instead of throwing exception');

      // Step 5: App should handle save attempts gracefully too
      const newProfile = Profile(
        role: UserRole.defender,
        language: 'fr',
        units: 'imperial',
        theme: 'light',
      );

      try {
        await prefsSource.saveProfile(newProfile);
        print('✅ GRACEFUL RECOVERY: Save operation handled without crashing');
      } catch (e) {
        fail('❌ Save operation crashed instead of handling gracefully: $e');
      }

      print('\n🎉 SUCCESS: App handles crashes gracefully!');
      print('   ✅ No exceptions thrown');
      print('   ✅ Safe fallback values returned');
      print('   ✅ Operations complete without crashing');
      print('   ✅ Requirement 4 VERIFIED\n');
    });
  });
}
