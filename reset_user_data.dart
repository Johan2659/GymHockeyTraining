/// Script to reset all user data - useful for testing the onboarding flow
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymhockeytraining/core/storage/hive_boxes.dart';
import 'package:gymhockeytraining/core/persistence/persistence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('\n🗑️  === RESETTING ALL USER DATA ===\n');

  try {
    // Initialize Hive
    print('📂 Initializing Hive...');
    await Hive.initFlutter();

    // Open all boxes (without encryption for this utility)
    print('📦 Opening Hive boxes...');
    for (final boxName in HiveBoxes.allBoxes) {
      try {
        if (!Hive.isBoxOpen(boxName)) {
          await Hive.openBox(boxName);
        }
        print('   ✓ Opened: $boxName');
      } catch (e) {
        print('   ⚠️  Could not open $boxName: $e');
      }
    }

    // Show current data before clearing
    print('\n📊 Current data:');
    for (final boxName in HiveBoxes.allBoxes) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          print('   $boxName: ${box.length} entries');
        }
      } catch (e) {
        print('   $boxName: Error reading ($e)');
      }
    }

    // Clear all boxes
    print('\n🧹 Clearing all data...');
    bool allSuccess = true;

    for (final boxName in HiveBoxes.allBoxes) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.clear();
          print('   ✓ Cleared: $boxName');
        }
      } catch (e) {
        print('   ❌ Failed to clear $boxName: $e');
        allSuccess = false;
      }
    }

    // Also clear via PersistenceService to handle fallbacks
    print('\n🔄 Clearing fallback storage...');
    await PersistenceService.clearAll();

    // Verify data is cleared
    print('\n✅ Verification:');
    for (final boxName in HiveBoxes.allBoxes) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          final count = box.length;
          if (count == 0) {
            print('   ✓ $boxName: Empty');
          } else {
            print('   ⚠️  $boxName: Still has $count entries');
            allSuccess = false;
          }
        }
      } catch (e) {
        print('   ❌ $boxName: Error ($e)');
      }
    }

    if (allSuccess) {
      print('\n🎉 SUCCESS! All user data has been deleted.');
      print('📱 You can now restart the app to experience the full onboarding flow.\n');
    } else {
      print('\n⚠️  WARNING: Some data may not have been cleared.');
      print('   Try restarting the app and running this script again.\n');
    }
  } catch (e, stackTrace) {
    print('\n❌ ERROR: Failed to reset user data');
    print('Error: $e');
    print('Stack trace: $stackTrace\n');
  }
}
