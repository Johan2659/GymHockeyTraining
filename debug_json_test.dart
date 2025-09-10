/// Test to see what the actual JSON looks like
import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/core/models/models.dart';
import 'dart:convert';

void main() {
  test('Debug JSON structure', () {
    final analytics = PerformanceAnalytics(
      categoryProgress: <ExerciseCategory, double>{
        ExerciseCategory.strength: 0.5,
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
      lastUpdated: DateTime(2025, 9, 10, 12, 0, 0),
    );

    final json = analytics.toJson();
    print('JSON structure:');
    print(jsonEncode(json));
    print('');
    print('weeklyStats type: ${json['weeklyStats'].runtimeType}');
    print('weeklyStats content: ${json['weeklyStats']}');
  });
}
