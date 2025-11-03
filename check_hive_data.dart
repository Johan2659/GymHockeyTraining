import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gymhockeytraining/core/storage/hive_boxes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  print('\n=== Checking Hive Boxes ===\n');

  try {
    // Check exercise_performance box
    print('1. Checking exercise_performance box...');
    Box<dynamic> perfBox;
    if (Hive.isBoxOpen(HiveBoxes.exercisePerformance)) {
      print('   Box is already open');
      perfBox = Hive.box(HiveBoxes.exercisePerformance);
    } else {
      print('   Opening box...');
      perfBox = await Hive.openBox(HiveBoxes.exercisePerformance);
    }

    print('   Total entries: ${perfBox.length}');
    print('   Keys: ${perfBox.keys.take(5).toList()}');

    if (perfBox.isEmpty) {
      print('   ❌ Box is EMPTY - No exercise performances saved yet');
      print('   → You need to complete some exercises first!');
    } else {
      print('\n   First 3 entries:');
      int count = 0;
      for (final key in perfBox.keys) {
        if (count >= 3) break;
        final value = perfBox.get(key);
        print('   - Key: $key');
        print('     Type: ${value.runtimeType}');
        if (value is Map) {
          print('     Exercise: ${value['exerciseName'] ?? 'Unknown'}');
          print('     Sets: ${(value['sets'] as List?)?.length ?? 0}');
        }
        count++;
      }
    }

    // Check other relevant boxes
    print('\n2. Checking other boxes...');
    final boxes = [
      'app_settings',
      'progress_journal',
      'user_profile',
      'sessions',
      'programs',
    ];

    for (final boxName in boxes) {
      try {
        Box<dynamic> box;
        if (Hive.isBoxOpen(boxName)) {
          box = Hive.box(boxName);
        } else {
          box = await Hive.openBox(boxName);
        }
        print('   $boxName: ${box.length} entries');
      } catch (e) {
        print('   $boxName: Error - $e');
      }
    }

    print('\n✅ Check complete!');
  } catch (e, stack) {
    print('❌ Error: $e');
    print(stack);
  }
}
