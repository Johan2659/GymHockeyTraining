import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gymhockeytraining/core/models/models.dart';

// Simple test to verify framework is working
void main() {
  group('Simple Tests', () {
    test('should create a ProgramState', () {
      const state = ProgramState(
        userId: 'test-user-1',
        activeProgramId: 'test',
        currentWeek: 0,
        currentSession: 0,
        completedExerciseIds: [],
      );

      expect(state.activeProgramId, equals('test'));
      expect(state.currentWeek, equals(0));
    });

    test('should create a ProgressEvent', () {
      final event = ProgressEvent(
        userId: 'test-user-1',
        ts: DateTime.now(),
        type: ProgressEventType.sessionStarted,
        programId: 'test',
        week: 0,
        session: 0,
      );

      expect(event.programId, equals('test'));
      expect(event.type, equals(ProgressEventType.sessionStarted));
    });
  });
}
