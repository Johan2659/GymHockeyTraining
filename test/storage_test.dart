import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/storage/hive_boxes.dart';

void main() {
  group('Storage Layer Tests', () {
    group('HiveBoxes', () {
      test('should have all required box names defined', () {
        expect(HiveBoxes.main, equals('main_storage'));
        expect(HiveBoxes.settings, equals('app_settings'));
        expect(HiveBoxes.profile, equals('user_profile'));
        expect(HiveBoxes.progress, equals('progress_journal'));
        expect(HiveBoxes.training, equals('training_data'));
        expect(HiveBoxes.migrations, equals('migration_metadata'));
        expect(HiveBoxes.allBoxes.length, equals(6));
      });

      test('should contain all box names in allBoxes list', () {
        expect(HiveBoxes.allBoxes, contains(HiveBoxes.main));
        expect(HiveBoxes.allBoxes, contains(HiveBoxes.settings));
        expect(HiveBoxes.allBoxes, contains(HiveBoxes.profile));
        expect(HiveBoxes.allBoxes, contains(HiveBoxes.progress));
        expect(HiveBoxes.allBoxes, contains(HiveBoxes.training));
        expect(HiveBoxes.allBoxes, contains(HiveBoxes.migrations));
      });

      test('should have unique box names', () {
        final boxNames = HiveBoxes.allBoxes;
        final uniqueNames = boxNames.toSet();
        expect(uniqueNames.length, equals(boxNames.length));
      });
    });
  });
}
