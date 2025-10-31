/// Simple integration test to verify performance analytics
import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/models/models.dart';

void main() {
  test('Performance Analytics Integration Test', () {
    // Test 1: Enum values are correct
    expect(ExerciseCategory.values.length, 8);
    expect(ExerciseCategory.strength.name, 'strength');
    expect(ExerciseCategory.power.name, 'power');

    // Test 2: Create a complete analytics object
    final analytics = PerformanceAnalytics(
      categoryProgress: <ExerciseCategory, double>{
        ExerciseCategory.strength: 0.75,
        ExerciseCategory.power: 0.50,
        ExerciseCategory.speed: 0.25,
        ExerciseCategory.agility: 0.60,
        ExerciseCategory.conditioning: 0.80,
        ExerciseCategory.technique: 0.40,
        ExerciseCategory.balance: 0.30,
        ExerciseCategory.flexibility: 0.20,
      },
      weeklyStats: const WeeklyStats(
        totalSessions: 4,
        totalExercises: 32,
        totalTrainingTime: 180,
        avgSessionDuration: 45.0,
        completionRate: 0.95,
        xpEarned: 480,
      ),
      streakData: const StreakData(
        currentStreak: 5,
        longestStreak: 12,
        weeklyGoal: 3,
        weeklyProgress: 3,
        lastTrainingDate: null,
      ),
      personalBests: <String, PersonalBest>{
        'squat': PersonalBest(
          exerciseId: 'squat',
          exerciseName: 'Squat',
          bestValue: 100.0,
          unit: 'kg',
          achievedAt: DateTime(2025, 9, 10),
          programId: 'attacker_program',
        ),
      },
      intensityTrends: <IntensityDataPoint>[
        IntensityDataPoint(
          date: DateTime(2025, 9, 10),
          intensity: 7.5,
          volume: 8,
          duration: 45,
        ),
      ],
      lastUpdated: DateTime(2025, 9, 10, 15, 30),
    );

    // Test 3: JSON serialization works
    final json = analytics.toJson();
    expect(json, isA<Map<String, dynamic>>());
    expect(json['categoryProgress'], isA<Map>());
    expect(json['weeklyStats'], isA<Map>());

    // Test 4: JSON deserialization works
    final restored = PerformanceAnalytics.fromJson(json);
    expect(restored.categoryProgress[ExerciseCategory.strength], 0.75);
    expect(restored.weeklyStats.totalSessions, 4);
    expect(restored.streakData.currentStreak, 5);
    expect(restored.personalBests['squat']?.bestValue, 100.0);
    expect(restored.intensityTrends.length, 1);

    print('✅ All performance analytics tests passed!');
    print(
        '📊 Category Progress: ${restored.categoryProgress.length} categories');
    print('📈 Weekly Stats: ${restored.weeklyStats.totalSessions} sessions');
    print('🔥 Streak: ${restored.streakData.currentStreak} days');
    print('🏆 Personal Bests: ${restored.personalBests.length} records');
    print(
        '📊 Intensity Trends: ${restored.intensityTrends.length} data points');
  });
}
