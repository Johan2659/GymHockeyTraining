/// Performance analytics repository implementation
import '../../core/models/models.dart';
import '../../core/repositories/performance_analytics_repository.dart';
import '../../core/repositories/exercise_repository.dart';
import '../../core/repositories/exercise_performance_repository.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/services/logger_service.dart';
import '../datasources/local_performance_source.dart';

class PerformanceAnalyticsRepositoryImpl
    implements PerformanceAnalyticsRepository {
  PerformanceAnalyticsRepositoryImpl({
    required LocalPerformanceSource dataSource,
    required ExerciseRepository exerciseRepository,
    required ExercisePerformanceRepository exercisePerformanceRepository,
    required AuthRepository authRepository,
  })  : _dataSource = dataSource,
        _exerciseRepository = exerciseRepository,
        _exercisePerformanceRepository = exercisePerformanceRepository,
        _authRepository = authRepository;

  final LocalPerformanceSource _dataSource;
  final ExerciseRepository _exerciseRepository;
  final ExercisePerformanceRepository _exercisePerformanceRepository;
  final AuthRepository _authRepository;

  @override
  Future<PerformanceAnalytics?> get() async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';
      return await _dataSource.getPerformanceAnalytics(userId);
    } catch (e) {
      LoggerService.instance.error('Failed to get performance analytics',
          error: e, source: 'PerformanceAnalyticsRepository');
      return null;
    }
  }

  @override
  Stream<PerformanceAnalytics?> watch() async* {
    final currentUser = await _authRepository.getCurrentUser();
    final userId = currentUser?.id ?? '';
    yield* _dataSource.watchPerformanceAnalytics(userId);
  }

  @override
  Future<void> save(PerformanceAnalytics analytics) async {
    try {
      await _dataSource.savePerformanceAnalytics(analytics);
    } catch (e) {
      LoggerService.instance.error('Failed to save performance analytics',
          error: e, source: 'PerformanceAnalyticsRepository');
      rethrow;
    }
  }

  @override
  Future<PerformanceAnalytics> calculateAnalytics(
    List<ProgressEvent> events,
    List<Program> programs,
    ProgramState? currentState,
  ) async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';
      
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final weeklyEvents =
          events.where((e) => e.ts.isAfter(startOfWeek)).toList();

      // Calculate category progress
      final categoryProgress =
          await _calculateCategoryProgress(events, programs, currentState);

      // Calculate weekly stats
      final weeklyStats = _calculateWeeklyStats(weeklyEvents);

      // Calculate streak data
      final streakData = _calculateStreakData(events);

      // Get existing data for personal bests and intensity trends
      final existing = await get();
      final personalBests = existing?.personalBests ?? <String, PersonalBest>{};
      final intensityTrends =
          existing?.intensityTrends ?? <IntensityDataPoint>[];

      // Add new intensity data point if we have session data today
      final todayEvents = events
          .where((e) =>
              e.ts.year == now.year &&
              e.ts.month == now.month &&
              e.ts.day == now.day)
          .toList();

      List<IntensityDataPoint> updatedTrends = List.from(intensityTrends);
      if (todayEvents.isNotEmpty) {
        final sessionEvents = todayEvents
            .where((e) => e.type == ProgressEventType.sessionCompleted)
            .toList();

        if (sessionEvents.isNotEmpty) {
          final intensity = _calculateSessionIntensity(todayEvents);
          final volume = todayEvents
              .where((e) => e.type == ProgressEventType.exerciseDone)
              .length;
          final duration = _estimateSessionDuration(todayEvents);

          updatedTrends.add(IntensityDataPoint(
            date: now,
            intensity: intensity,
            volume: volume,
            duration: duration,
          ));

          // Keep only last 30 days
          updatedTrends = updatedTrends
              .where((dp) =>
                  dp.date.isAfter(now.subtract(const Duration(days: 30))))
              .toList();
        }
      }

      return PerformanceAnalytics(
        userId: userId,
        categoryProgress: categoryProgress,
        weeklyStats: weeklyStats,
        streakData: streakData,
        personalBests: personalBests,
        intensityTrends: updatedTrends,
        lastUpdated: now,
      );
    } catch (e) {
      LoggerService.instance.error('Failed to calculate performance analytics',
          error: e, source: 'PerformanceAnalyticsRepository');
      rethrow;
    }
  }

  @override
  Future<void> updateCategoryProgress(
    String exerciseId,
    ExerciseCategory category,
    String programId,
  ) async {
    try {
      final current = await get();
      if (current == null) return;

      final updatedProgress =
          Map<ExerciseCategory, double>.from(current.categoryProgress);
      final currentProgress = updatedProgress[category] ?? 0.0;

      // Increment by small amount per exercise completion
      updatedProgress[category] = (currentProgress + 0.01).clamp(0.0, 1.0);

      final updated = current.copyWith(
        categoryProgress: updatedProgress,
        lastUpdated: DateTime.now(),
      );

      await save(updated);
    } catch (e) {
      LoggerService.instance.error('Failed to update category progress',
          error: e, source: 'PerformanceAnalyticsRepository');
    }
  }

  @override
  Future<void> recordPersonalBest(PersonalBest personalBest) async {
    try {
      final current = await get();
      if (current == null) return;

      final updatedBests =
          Map<String, PersonalBest>.from(current.personalBests);
      updatedBests[personalBest.exerciseId] = personalBest;

      final updated = current.copyWith(
        personalBests: updatedBests,
        lastUpdated: DateTime.now(),
      );

      await save(updated);
    } catch (e) {
      LoggerService.instance.error('Failed to record personal best',
          error: e, source: 'PerformanceAnalyticsRepository');
    }
  }

  @override
  Future<void> updateIntensityData(IntensityDataPoint dataPoint) async {
    try {
      final current = await get();
      if (current == null) return;

      final updatedTrends =
          List<IntensityDataPoint>.from(current.intensityTrends);
      updatedTrends.add(dataPoint);

      // Keep only last 30 days
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      updatedTrends.removeWhere((dp) => dp.date.isBefore(cutoffDate));

      final updated = current.copyWith(
        intensityTrends: updatedTrends,
        lastUpdated: DateTime.now(),
      );

      await save(updated);
    } catch (e) {
      LoggerService.instance.error('Failed to update intensity data',
          error: e, source: 'PerformanceAnalyticsRepository');
    }
  }

  // Private helper methods
  Future<Map<ExerciseCategory, double>> _calculateCategoryProgress(
    List<ProgressEvent> events,
    List<Program> programs,
    ProgramState? currentState,
  ) async {
    try {
      // Get ALL exercise performances for the user (lifetime stats)
      final allPerformances = await _exercisePerformanceRepository.getAll();

      LoggerService.instance.info(
        'Calculating category progress: ${allPerformances.length} performances found',
        source: 'PerformanceAnalyticsRepository',
      );

      if (allPerformances.isEmpty) {
        LoggerService.instance.warning(
          'No performances found - returning empty map',
          source: 'PerformanceAnalyticsRepository',
        );
        return <ExerciseCategory, double>{};
      }

      // Define the main 5 categories for hockey training radar
      const mainCategories = {
        ExerciseCategory.power,
        ExerciseCategory.strength,
        ExerciseCategory.speed,
        ExerciseCategory.conditioning,
        ExerciseCategory.agility,
      };

      // Initialize category volumes
      final categoryVolumes = <ExerciseCategory, double>{
        for (final category in mainCategories) category: 0.0,
      };

      int matchedCount = 0;
      int skippedCount = 0;

      // Group performances by session (programId + week + session + timestamp)
      final sessionMap = <String, List<ExercisePerformance>>{};
      
      for (final performance in allPerformances) {
        // Create session key: date-based grouping (same day = same session)
        final sessionKey = '${performance.programId}_${performance.timestamp.year}_${performance.timestamp.month}_${performance.timestamp.day}_${performance.timestamp.hour}';
        sessionMap.putIfAbsent(sessionKey, () => []).add(performance);
      }

      LoggerService.instance.info(
        'Grouped into ${sessionMap.length} unique sessions',
        source: 'PerformanceAnalyticsRepository',
      );

      // Analyze each session and determine its primary focus
      for (final sessionPerformances in sessionMap.values) {
        // Count exercises by category in this session
        final sessionCategoryCounts = <ExerciseCategory, int>{
          for (final category in mainCategories) category: 0,
        };

        for (final performance in sessionPerformances) {
          final exercise = await _exerciseRepository.getById(performance.exerciseId);
          if (exercise == null) {
            skippedCount++;
            continue;
          }

          if (!mainCategories.contains(exercise.category)) {
            skippedCount++;
            continue;
          }

          matchedCount++;
          sessionCategoryCounts[exercise.category] = 
              (sessionCategoryCounts[exercise.category] ?? 0) + 1;
        }

        // Find the dominant category in this session (category with most exercises)
        ExerciseCategory? dominantCategory;
        int maxCount = 0;
        
        for (final entry in sessionCategoryCounts.entries) {
          if (entry.value > maxCount) {
            maxCount = entry.value;
            dominantCategory = entry.key;
          }
        }

        // Award session points based on exercises done
        // Dominant category gets bonus to reflect session focus
        if (dominantCategory != null) {
          for (final entry in sessionCategoryCounts.entries) {
            if (entry.value > 0) {
              // Dominant category gets 50% bonus, others get base points
              final isDominant = entry.key == dominantCategory;
              final basePoints = entry.value.toDouble();
              final bonusMultiplier = isDominant ? 1.5 : 1.0;
              
              categoryVolumes[entry.key] = 
                  (categoryVolumes[entry.key] ?? 0.0) + (basePoints * bonusMultiplier);
            }
          }
        }
      }

      LoggerService.instance.info(
        'Category calculation complete: Matched=$matchedCount, Skipped=$skippedCount',
        source: 'PerformanceAnalyticsRepository',
      );

      // Log the results
      final totalVolume = categoryVolumes.values.fold(0.0, (sum, v) => sum + v);
      for (final category in mainCategories) {
        final volume = categoryVolumes[category] ?? 0.0;
        final percentage = totalVolume > 0 ? (volume / totalVolume * 100) : 0.0;
        LoggerService.instance.info(
          '  ${category.name}: ${volume.toStringAsFixed(1)} (${percentage.toStringAsFixed(1)}%)',
          source: 'PerformanceAnalyticsRepository',
        );
      }

      return categoryVolumes;
    } catch (e) {
      LoggerService.instance.error('Failed to calculate category progress',
          error: e, source: 'PerformanceAnalyticsRepository');
      return <ExerciseCategory, double>{};
    }
  }

  WeeklyStats _calculateWeeklyStats(List<ProgressEvent> weeklyEvents) {
    final sessionEvents = weeklyEvents
        .where((e) => e.type == ProgressEventType.sessionCompleted)
        .toList();

    final exerciseEvents = weeklyEvents
        .where((e) => e.type == ProgressEventType.exerciseDone)
        .toList();

    final bonusEvents = weeklyEvents
        .where((e) => e.type == ProgressEventType.bonusDone)
        .toList();

    final totalSessions = sessionEvents.length;
    final totalExercises = exerciseEvents.length;
    final totalTrainingTime = totalSessions * 45; // Estimate 45 min per session
    final avgSessionDuration =
        totalSessions > 0 ? totalTrainingTime / totalSessions : 0.0;
    final completionRate =
        totalSessions > 0 ? 1.0 : 0.8; // Simplified calculation
    final xpEarned = (totalExercises * 10) +
        (totalSessions * 50) +
        (bonusEvents.length * 25);

    return WeeklyStats(
      totalSessions: totalSessions,
      totalExercises: totalExercises,
      totalTrainingTime: totalTrainingTime,
      avgSessionDuration: avgSessionDuration,
      completionRate: completionRate,
      xpEarned: xpEarned,
    );
  }

  StreakData _calculateStreakData(List<ProgressEvent> events) {
    final sessionEvents = events
        .where((e) => e.type == ProgressEventType.sessionCompleted)
        .toList()
      ..sort((a, b) => b.ts.compareTo(a.ts));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    for (final event in sessionEvents.reversed) {
      final eventDate = DateTime(event.ts.year, event.ts.month, event.ts.day);

      if (lastDate == null) {
        tempStreak = 1;
        lastDate = eventDate;
      } else {
        final daysDiff = eventDate.difference(lastDate).inDays;
        if (daysDiff == 1) {
          tempStreak++;
        } else if (daysDiff > 1) {
          longestStreak =
              longestStreak > tempStreak ? longestStreak : tempStreak;
          tempStreak = 1;
        }
        lastDate = eventDate;
      }
    }

    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;

    // Calculate current streak (consecutive days from today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDate != null) {
      final daysSinceLastSession = today.difference(lastDate).inDays;
      if (daysSinceLastSession <= 1) {
        currentStreak = tempStreak;
      }
    }

    // Calculate weekly progress
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weeklySessionCount =
        sessionEvents.where((e) => e.ts.isAfter(startOfWeek)).length;

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyGoal: 3, // Default weekly goal
      weeklyProgress: weeklySessionCount,
      lastTrainingDate:
          sessionEvents.isNotEmpty ? sessionEvents.first.ts : null,
    );
  }

  double _calculateSessionIntensity(List<ProgressEvent> sessionEvents) {
    final exerciseCount = sessionEvents
        .where((e) => e.type == ProgressEventType.exerciseDone)
        .length;

    final bonusCount = sessionEvents
        .where((e) => e.type == ProgressEventType.bonusDone)
        .length;

    // Base intensity on exercise count and bonus completions
    double intensity = 5.0; // Base intensity
    intensity += (exerciseCount * 0.1).clamp(0.0, 3.0);
    intensity += (bonusCount * 0.5).clamp(0.0, 2.0);

    return intensity.clamp(1.0, 10.0);
  }

  int _estimateSessionDuration(List<ProgressEvent> sessionEvents) {
    if (sessionEvents.length < 2) return 30; // Default 30 minutes

    final sortedEvents = sessionEvents..sort((a, b) => a.ts.compareTo(b.ts));
    final duration =
        sortedEvents.last.ts.difference(sortedEvents.first.ts).inMinutes;

    return duration.clamp(15, 120); // Between 15 and 120 minutes
  }

  @override
  Future<bool> clear() async {
    try {
      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';
      
      LoggerService.instance.warning('Clearing performance analytics data',
          source: 'PerformanceAnalyticsRepository');

      // We'll clear by saving a reset analytics object
      final resetAnalytics = PerformanceAnalytics(
        userId: userId,
        categoryProgress: <ExerciseCategory, double>{
          for (final category in ExerciseCategory.values) category: 0.0,
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

      await save(resetAnalytics);
      LoggerService.instance.info('Performance analytics cleared successfully',
          source: 'PerformanceAnalyticsRepository');
      return true;
    } catch (e) {
      LoggerService.instance.error('Failed to clear performance analytics',
          error: e, source: 'PerformanceAnalyticsRepository');
      return false;
    }
  }
}
