/// Performance analytics repository interface
import '../models/models.dart';

abstract class PerformanceAnalyticsRepository {
  /// Get current performance analytics
  Future<PerformanceAnalytics?> get();
  
  /// Watch performance analytics changes
  Stream<PerformanceAnalytics?> watch();
  
  /// Update performance analytics
  Future<void> save(PerformanceAnalytics analytics);
  
  /// Calculate performance analytics from progress events
  Future<PerformanceAnalytics> calculateAnalytics(
    List<ProgressEvent> events,
    List<Program> programs,
    ProgramState? currentState,
  );
  
  /// Update category progress based on completed exercises
  Future<void> updateCategoryProgress(
    String exerciseId,
    ExerciseCategory category,
    String programId,
  );
  
  /// Record a personal best
  Future<void> recordPersonalBest(PersonalBest personalBest);
  
  /// Update training intensity data
  Future<void> updateIntensityData(IntensityDataPoint dataPoint);
  
  /// Clear all performance analytics data
  Future<bool> clear();
}
