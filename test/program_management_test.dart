import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/data/datasources/local_progress_source.dart';
import '../lib/features/programs/application/program_management_controller.dart';
import '../lib/core/models/models.dart';

/// Test suite for the program management deletion feature
/// Verifies that program deletion works correctly and maintains data integrity
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock platform channels
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return './test/documents/';
      }
      if (methodCall.method == 'getTemporaryDirectory') {
        return './test/temp/';
      }
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return './test/support/';
      }
      return './test/';
    });
    
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
        .setMockMethodCallHandler((MethodCall methodCall) async => null);
    
    // Initialize Hive with test directory
    await Hive.initFlutter();
    
    // Open required boxes
    try {
      await Hive.openBox('progress_journal');
      await Hive.openBox('user_profile');
      await Hive.openBox('app_settings');
    } catch (e) {
      // Boxes might already be open
    }
  });

  tearDownAll(() async {
    // Clean up Hive
    try {
      if (Hive.isBoxOpen('progress_journal')) {
        final box = Hive.box('progress_journal');
        await box.clear();
        await box.close();
      }
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
    } catch (e) {
      // Ignore cleanup errors
    }
    
    await Hive.deleteFromDisk();
  });

  group('Program Management Tests', () {
    
    group('Local Progress Source - Delete by Program', () {
      late LocalProgressSource source;

      setUp(() async {
        source = LocalProgressSource();
        // Clean any existing data before each test
        await source.clearAllEvents();
      });

      tearDown(() async {
        // Clean up after each test
        await source.clearAllEvents();
      });

      test('should delete events for specific program only', () async {
        
        // Create test events for different programs
        final program1Event1 = ProgressEvent(
          ts: DateTime.now(),
          type: ProgressEventType.sessionStarted,
          programId: 'program1',
          week: 0,
          session: 0,
        );
        
        final program1Event2 = ProgressEvent(
          ts: DateTime.now().add(const Duration(minutes: 30)),
          type: ProgressEventType.sessionCompleted,
          programId: 'program1',
          week: 0,
          session: 0,
        );
        
        final program2Event = ProgressEvent(
          ts: DateTime.now().add(const Duration(hours: 1)),
          type: ProgressEventType.sessionStarted,
          programId: 'program2',
          week: 0,
          session: 0,
        );
        
        // Add events to storage
        await source.appendEvent(program1Event1);
        await source.appendEvent(program1Event2);
        await source.appendEvent(program2Event);
        
        // Verify all events were added
        final allEvents = await source.getAllEvents();
        expect(allEvents.length, equals(3));
        
        // Get events for each program
        final program1Events = await source.getEventsByProgram('program1');
        final program2Events = await source.getEventsByProgram('program2');
        
        expect(program1Events.length, equals(2));
        expect(program2Events.length, equals(1));
        
        // Delete program1 events
        final deleteSuccess = await source.deleteEventsByProgram('program1');
        expect(deleteSuccess, isTrue);
        
        // Verify program1 events are deleted
        final remainingProgram1Events = await source.getEventsByProgram('program1');
        expect(remainingProgram1Events.length, equals(0));
        
        // Verify program2 events are still there
        final remainingProgram2Events = await source.getEventsByProgram('program2');
        expect(remainingProgram2Events.length, equals(1));
        
        // Verify total events count
        final remainingAllEvents = await source.getAllEvents();
        expect(remainingAllEvents.length, equals(1));
      });

      test('should handle deleting from non-existent program gracefully', () async {
        // Try to delete events for a program that doesn't exist
        final deleteSuccess = await source.deleteEventsByProgram('non_existent_program');
        expect(deleteSuccess, isTrue); // Should succeed (no-op)
        
        // Verify no events exist
        final allEvents = await source.getAllEvents();
        expect(allEvents.length, equals(0));
      });

      test('should preserve event data integrity after deletion', () async {
        // Create test event with complex data
        final complexEvent = ProgressEvent(
          ts: DateTime.now(),
          type: ProgressEventType.exerciseDone,
          programId: 'test_program',
          week: 2,
          session: 1,
          exerciseId: 'bench_press',
          payload: {'sets': 4, 'reps': 8, 'weight': 100},
        );
        
        final otherEvent = ProgressEvent(
          ts: DateTime.now().add(const Duration(minutes: 10)),
          type: ProgressEventType.sessionCompleted,
          programId: 'other_program',
          week: 1,
          session: 2,
        );
        
        // Add events
        await source.appendEvent(complexEvent);
        await source.appendEvent(otherEvent);
        
        // Delete test_program events
        await source.deleteEventsByProgram('test_program');
        
        // Verify remaining event has intact data
        final remainingEvents = await source.getAllEvents();
        expect(remainingEvents.length, equals(1));
        
        final remaining = remainingEvents.first;
        expect(remaining.programId, equals('other_program'));
        expect(remaining.week, equals(1));
        expect(remaining.session, equals(2));
        expect(remaining.type, equals(ProgressEventType.sessionCompleted));
      });
    });

    group('Program Deletion Options', () {
      test('should have correct enum values', () {
        expect(ProgramDeletionOption.values.length, equals(3));
        expect(ProgramDeletionOption.values, contains(ProgramDeletionOption.stopOnly));
        expect(ProgramDeletionOption.values, contains(ProgramDeletionOption.stopAndDeleteProgress));
        expect(ProgramDeletionOption.values, contains(ProgramDeletionOption.stopAndDeleteEverything));
      });

      test('should handle enum comparison correctly', () {
        const option1 = ProgramDeletionOption.stopOnly;
        const option2 = ProgramDeletionOption.stopAndDeleteProgress;
        const option3 = ProgramDeletionOption.stopAndDeleteEverything;
        
        expect(option1 == ProgramDeletionOption.stopOnly, isTrue);
        expect(option1 == option2, isFalse);
        expect(option2 == option3, isFalse);
      });
    });

    group('SSOT Validation', () {
      test('should verify that all program data sources clear progress consistently', () async {
        final source = LocalProgressSource();
        
        // Create events for the same program we'll later delete
        final event1 = ProgressEvent(
          ts: DateTime.now(),
          type: ProgressEventType.sessionStarted,
          programId: 'test_program',
          week: 0,
          session: 0,
        );
        
        final event2 = ProgressEvent(
          ts: DateTime.now().add(const Duration(minutes: 30)),
          type: ProgressEventType.exerciseDone,
          programId: 'test_program',
          week: 0,
          session: 0,
          exerciseId: 'squat',
        );
        
        final event3 = ProgressEvent(
          ts: DateTime.now().add(const Duration(hours: 1)),
          type: ProgressEventType.sessionCompleted,
          programId: 'test_program',
          week: 0,
          session: 0,
        );
        
        // Add events
        await source.appendEvent(event1);
        await source.appendEvent(event2);
        await source.appendEvent(event3);
        
        // Verify events exist
        final beforeDeletion = await source.getAllEvents();
        expect(beforeDeletion.length, equals(3));
        
        final programEvents = await source.getEventsByProgram('test_program');
        expect(programEvents.length, equals(3));
        
        // Delete program events
        await source.deleteEventsByProgram('test_program');
        
        // Verify all events for this program are gone
        final afterDeletion = await source.getAllEvents();
        expect(afterDeletion.length, equals(0));
        
        final remainingProgramEvents = await source.getEventsByProgram('test_program');
        expect(remainingProgramEvents.length, equals(0));
        
        // This test verifies that our single source of truth (LocalProgressSource)
        // correctly manages all program-related progress data
      });
    });
  });
}
