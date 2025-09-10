import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/repositories/repositories.dart';
import '../data/repositories_impl/repositories_impl.dart';
import '../data/datasources/datasources.dart';
import '../data/datasources/local_performance_source.dart';

part 'di.g.dart';

/// Dependency injection providers for the Hockey Gym app
/// Provides singleton instances of repositories and data sources

// =============================================================================
// Core Services
// =============================================================================

// Logger provider
@riverpod
Logger logger(Ref ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );
}

// =============================================================================
// Data Sources
// =============================================================================

/// Provider for local program data source
@riverpod
LocalProgramSource localProgramSource(Ref ref) {
  return LocalProgramSource();
}

/// Provider for local progress data source
@riverpod
LocalProgressSource localProgressSource(Ref ref) {
  return LocalProgressSource();
}

/// Provider for local preferences data source
@riverpod
LocalPrefsSource localPrefsSource(Ref ref) {
  return LocalPrefsSource();
}

/// Provider for local session data source
@riverpod
LocalSessionSource localSessionSource(Ref ref) {
  return LocalSessionSource();
}

/// Provider for local exercise data source
@riverpod
LocalExerciseSource localExerciseSource(Ref ref) {
  return LocalExerciseSource();
}

/// Provider for local extras data source
@riverpod
LocalExtrasSource localExtrasSource(Ref ref) {
  return LocalExtrasSource();
}

/// Provider for local performance analytics data source
@riverpod
LocalPerformanceSource localPerformanceSource(Ref ref) {
  return LocalPerformanceSource();
}

// =============================================================================
// Repository Implementations
// =============================================================================

/// Provider for program repository
@riverpod
ProgramRepository programRepository(Ref ref) {
  final localSource = ref.watch(localProgramSourceProvider);
  return ProgramRepositoryImpl(localSource: localSource);
}

/// Provider for progress repository
@riverpod
ProgressRepository progressRepository(Ref ref) {
  final localSource = ref.watch(localProgressSourceProvider);
  return ProgressRepositoryImpl(localSource: localSource);
}

/// Provider for program state repository
@riverpod
ProgramStateRepository programStateRepository(Ref ref) {
  final localSource = ref.watch(localPrefsSourceProvider);
  return ProgramStateRepositoryImpl(localSource: localSource);
}

/// Provider for profile repository
@riverpod
ProfileRepository profileRepository(Ref ref) {
  final localSource = ref.watch(localPrefsSourceProvider);
  return ProfileRepositoryImpl(localSource: localSource);
}

/// Provider for session repository
@riverpod
SessionRepository sessionRepository(Ref ref) {
  final localSource = ref.watch(localSessionSourceProvider);
  return SessionRepositoryImpl(localSource: localSource);
}

/// Provider for exercise repository
@riverpod
ExerciseRepository exerciseRepository(Ref ref) {
  final localSource = ref.watch(localExerciseSourceProvider);
  return ExerciseRepositoryImpl(localSource: localSource);
}

/// Provider for extras repository
@riverpod
ExtrasRepository extrasRepository(Ref ref) {
  final localSource = ref.watch(localExtrasSourceProvider);
  return ExtrasRepositoryImpl(localSource: localSource);
}

/// Provider for performance analytics repository
@riverpod
PerformanceAnalyticsRepository performanceAnalyticsRepository(Ref ref) {
  final dataSource = ref.watch(localPerformanceSourceProvider);
  return PerformanceAnalyticsRepositoryImpl(dataSource: dataSource);
}
