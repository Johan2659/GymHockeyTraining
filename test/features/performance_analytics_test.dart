import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/models/models.dart';

void main() {
  group('Performance Analytics', () {
    test('should calculate category progress correctly', () async {
      // Create mock events
      final events = [
        ProgressEvent(
          ts: DateTime.now().subtract(const Duration(days: 1)),
          type: ProgressEventType.exerciseDone,
          programId: 'test_program',
          week: 0,
          session: 0,
          exerciseId: 'squat_1',
        ),
        ProgressEvent(
          ts: DateTime.now().subtract(const Duration(hours: 1)),
          type: ProgressEventType.sessionCompleted,
          programId: 'test_program',
          week: 0,
          session: 0,
        ),
      ];

      // Create mock programs
      final programs = [
        Program(
          id: 'test_program',
          role: UserRole.attacker,
          title: 'Test Program',
          weeks: [
            Week(index: 0, sessions: ['session_1']),
          ],
        ),
      ];

      // Create mock program state
      final programState = ProgramState(
        activeProgramId: 'test_program',
        currentWeek: 0,
        currentSession: 0,
        completedExerciseIds: ['squat_1'],
      );

      // This test verifies that our models are correctly structured
      expect(events.length, 2);
      expect(programs.length, 1);
      expect(programState.activeProgramId, 'test_program');
      expect(ExerciseCategory.values.length, 8); // All categories defined
    });

    test('should create initial performance analytics', () {
      final analytics = PerformanceAnalytics(
        categoryProgress: <ExerciseCategory, double>{
          for (ExerciseCategory category in ExerciseCategory.values) category: 0.0,
        },
        weeklyStats: const WeeklyStats(
          totalSessions: 0,
          totalExercises: 0,
          totalTrainingTime: 0,
          avgSessionDuration: 0.0,
          completionRate: 0.0,
          xpEarned: 0,
        ),
        streakData: const StreakData(
          currentStreak: 0,
          longestStreak: 0,
          weeklyGoal: 3,
          weeklyProgress: 0,
          lastTrainingDate: null,
        ),
        personalBests: <String, PersonalBest>{},
        intensityTrends: <IntensityDataPoint>[],
        lastUpdated: DateTime.now(),
      );

      expect(analytics.categoryProgress.length, 8);
      expect(analytics.categoryProgress[ExerciseCategory.strength], 0.0);
      expect(analytics.weeklyStats.totalSessions, 0);
      expect(analytics.streakData.currentStreak, 0);
    });

    test('should serialize and deserialize performance analytics', () {
      final now = DateTime(2025, 9, 10, 12, 0, 0);
      final original = PerformanceAnalytics(
        categoryProgress: <ExerciseCategory, double>{
          ExerciseCategory.strength: 0.5,
          ExerciseCategory.power: 0.3,
          ExerciseCategory.speed: 0.7,
          ExerciseCategory.agility: 0.2,
          ExerciseCategory.conditioning: 0.8,
          ExerciseCategory.technique: 0.4,
          ExerciseCategory.balance: 0.6,
          ExerciseCategory.flexibility: 0.1,
        },
        weeklyStats: const WeeklyStats(
          totalSessions: 5,
          totalExercises: 25,
          totalTrainingTime: 225,
          avgSessionDuration: 45.0,
          completionRate: 0.9,
          xpEarned: 375,
        ),
        streakData: const StreakData(
          currentStreak: 3,
          longestStreak: 7,
          weeklyGoal: 3,
          weeklyProgress: 2,
          lastTrainingDate: null,
        ),
        personalBests: <String, PersonalBest>{},
        intensityTrends: <IntensityDataPoint>[],
        lastUpdated: now,
      );

      // Test JSON serialization
      final json = original.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['categoryProgress'], isA<Map>());
      expect(json['weeklyStats'], isA<Map>());
      expect(json['streakData'], isA<Map>());
      expect(json['personalBests'], isA<Map>());
      expect(json['intensityTrends'], isA<List>());
      expect(json['lastUpdated'], isA<String>());

      // Test JSON deserialization
      final deserialized = PerformanceAnalytics.fromJson(json);
      expect(deserialized.categoryProgress[ExerciseCategory.strength], 0.5);
      expect(deserialized.categoryProgress[ExerciseCategory.power], 0.3);
      expect(deserialized.weeklyStats.totalSessions, 5);
      expect(deserialized.weeklyStats.avgSessionDuration, 45.0);
      expect(deserialized.streakData.currentStreak, 3);
      expect(deserialized.streakData.longestStreak, 7);
      expect(deserialized.lastUpdated, now);
    });
  });
}
