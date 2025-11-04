/// Domain models for the Hockey Gym app
library;

import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// User role enum for different hockey positions
enum UserRole {
  @JsonValue('attacker')
  attacker,
  @JsonValue('defender')
  defender,
  @JsonValue('goalie')
  goalie,
  @JsonValue('referee')
  referee,
}

/// Progress event type enum for tracking different types of events
enum ProgressEventType {
  @JsonValue('session_started')
  sessionStarted,
  @JsonValue('exercise_done')
  exerciseDone,
  @JsonValue('session_completed')
  sessionCompleted,
  @JsonValue('bonus_done')
  bonusDone,
  @JsonValue('extra_completed')
  extraCompleted,
}

/// Extra type enum for different categories of extras
enum ExtraType {
  @JsonValue('express_workout')
  expressWorkout,
  @JsonValue('bonus_challenge')
  bonusChallenge,
  @JsonValue('mobility_recovery')
  mobilityRecovery,
}

/// Exercise category enum for tracking performance metrics
enum ExerciseCategory {
  @JsonValue('strength')
  strength,
  @JsonValue('power')
  power,
  @JsonValue('speed')
  speed,
  @JsonValue('agility')
  agility,
  @JsonValue('conditioning')
  conditioning,
  @JsonValue('technique')
  technique,
  @JsonValue('balance')
  balance,
  @JsonValue('flexibility')
  flexibility,
  @JsonValue('warmup')
  warmup,
  @JsonValue('recovery')
  recovery,
  @JsonValue('stick_skills')
  stickSkills,
  @JsonValue('game_situation')
  gameSituation,
}

/// Exercise model representing a single exercise
@JsonSerializable()
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.sets,
    required this.reps,
    this.duration,
    this.rest,
    required this.youtubeQuery,
    this.gymAltId,
    this.homeAltId,
    this.tracksWeight,
  });

  final String id;
  final String name;
  final ExerciseCategory category;
  final int sets;
  final int reps;
  final int? duration; // in seconds
  final int? rest; // in seconds
  final String youtubeQuery;
  final String? gymAltId;
  final String? homeAltId;
  final bool? tracksWeight; // Whether this exercise tracks weight (null/true = yes, false = no weight needed)

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Exercise block representing an exercise within a session
@JsonSerializable()
class ExerciseBlock {
  const ExerciseBlock({
    required this.exerciseId,
    this.swapGymId,
    this.swapHomeId,
  });

  final String exerciseId;
  final String? swapGymId;
  final String? swapHomeId;

  factory ExerciseBlock.fromJson(Map<String, dynamic> json) =>
      _$ExerciseBlockFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseBlockToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseBlock &&
          runtimeType == other.runtimeType &&
          exerciseId == other.exerciseId;

  @override
  int get hashCode => exerciseId.hashCode;
}

/// Session model representing a training session
@JsonSerializable()
class Session {
  const Session({
    required this.id,
    required this.title,
    required this.blocks,
    required this.bonusChallenge,
  });

  final String id;
  final String title;
  @JsonKey(fromJson: _blocksFromJson, toJson: _blocksToJson)
  final List<ExerciseBlock> blocks;
  final String bonusChallenge;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<ExerciseBlock> _blocksFromJson(List<dynamic> json) => json
      .map((e) => ExerciseBlock.fromJson(e as Map<String, dynamic>))
      .toList();

  static List<Map<String, dynamic>> _blocksToJson(List<ExerciseBlock> blocks) =>
      blocks.map((e) => e.toJson()).toList();
}

/// Week model representing a week in a training program
@JsonSerializable()
class Week {
  const Week({
    required this.index,
    required this.sessions,
  });

  final int index;
  final List<String> sessions; // List of session IDs

  factory Week.fromJson(Map<String, dynamic> json) => _$WeekFromJson(json);
  Map<String, dynamic> toJson() => _$WeekToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Week && runtimeType == other.runtimeType && index == other.index;

  @override
  int get hashCode => index.hashCode;
}

/// Program model representing a complete training program
@JsonSerializable()
class Program {
  const Program({
    required this.id,
    required this.role,
    required this.title,
    required this.weeks,
  });

  final String id;
  final UserRole role;
  final String title;
  @JsonKey(fromJson: _weeksFromJson, toJson: _weeksToJson)
  final List<Week> weeks;

  factory Program.fromJson(Map<String, dynamic> json) =>
      _$ProgramFromJson(json);
  Map<String, dynamic> toJson() => _$ProgramToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Program && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<Week> _weeksFromJson(List<dynamic> json) =>
      json.map((e) => Week.fromJson(e as Map<String, dynamic>)).toList();

  static List<Map<String, dynamic>> _weeksToJson(List<Week> weeks) =>
      weeks.map((e) => e.toJson()).toList();
}

/// Session in progress model for paused sessions
@JsonSerializable()
class SessionInProgress {
  const SessionInProgress({
    required this.programId,
    required this.week,
    required this.session,
    required this.currentPage,
    required this.completedExercises,
    required this.exercisePerformances,
    this.lastWeightUsed,
    required this.pausedAt,
  });

  final String programId;
  final int week;
  final int session;
  final int currentPage;
  final List<String> completedExercises;
  final Map<String, dynamic> exercisePerformances; // Stored as dynamic JSON
  final Map<String, double>? lastWeightUsed;
  final DateTime pausedAt;

  factory SessionInProgress.fromJson(Map<String, dynamic> json) =>
      _$SessionInProgressFromJson(json);
  Map<String, dynamic> toJson() => _$SessionInProgressToJson(this);

  SessionInProgress copyWith({
    String? programId,
    int? week,
    int? session,
    int? currentPage,
    List<String>? completedExercises,
    Map<String, dynamic>? exercisePerformances,
    Map<String, double>? lastWeightUsed,
    DateTime? pausedAt,
  }) {
    return SessionInProgress(
      programId: programId ?? this.programId,
      week: week ?? this.week,
      session: session ?? this.session,
      currentPage: currentPage ?? this.currentPage,
      completedExercises: completedExercises ?? this.completedExercises,
      exercisePerformances: exercisePerformances ?? this.exercisePerformances,
      lastWeightUsed: lastWeightUsed ?? this.lastWeightUsed,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }
}

/// Program state model for tracking user progress in a program
@JsonSerializable()
class ProgramState {
  const ProgramState({
    this.activeProgramId,
    required this.currentWeek,
    required this.currentSession,
    required this.completedExerciseIds,
    this.pausedAt,
    this.sessionInProgress,
  });

  final String? activeProgramId;
  final int currentWeek;
  final int currentSession;
  final List<String> completedExerciseIds;
  final DateTime? pausedAt;
  @JsonKey(
      fromJson: _sessionInProgressFromJson, toJson: _sessionInProgressToJson)
  final SessionInProgress? sessionInProgress;

  factory ProgramState.fromJson(Map<String, dynamic> json) =>
      _$ProgramStateFromJson(json);
  Map<String, dynamic> toJson() => _$ProgramStateToJson(this);

  ProgramState copyWith({
    String? activeProgramId,
    int? currentWeek,
    int? currentSession,
    List<String>? completedExerciseIds,
    DateTime? pausedAt,
    SessionInProgress? sessionInProgress,
    bool clearSessionInProgress = false,
  }) {
    return ProgramState(
      activeProgramId: activeProgramId ?? this.activeProgramId,
      currentWeek: currentWeek ?? this.currentWeek,
      currentSession: currentSession ?? this.currentSession,
      completedExerciseIds: completedExerciseIds ?? this.completedExerciseIds,
      pausedAt: pausedAt ?? this.pausedAt,
      sessionInProgress: clearSessionInProgress
          ? null
          : (sessionInProgress ?? this.sessionInProgress),
    );
  }

  static SessionInProgress? _sessionInProgressFromJson(
          Map<String, dynamic>? json) =>
      json == null ? null : SessionInProgress.fromJson(json);

  static Map<String, dynamic>? _sessionInProgressToJson(
          SessionInProgress? session) =>
      session?.toJson();
}

/// Progress event model for journaling training events
@JsonSerializable()
class ProgressEvent {
  const ProgressEvent({
    required this.ts,
    required this.type,
    required this.programId,
    required this.week,
    required this.session,
    this.exerciseId,
    this.payload,
  });

  final DateTime ts;
  final ProgressEventType type;
  final String programId;
  final int week;
  final int session;
  final String? exerciseId;
  final Map<String, dynamic>? payload;

  factory ProgressEvent.fromJson(Map<String, dynamic> json) =>
      _$ProgressEventFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressEventToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressEvent &&
          runtimeType == other.runtimeType &&
          ts == other.ts &&
          type == other.type;

  @override
  int get hashCode => Object.hash(ts, type);
}

/// Profile model for user preferences and settings
@JsonSerializable()
class Profile {
  const Profile({
    this.role,
    this.language,
    this.units,
    this.theme,
  });

  final UserRole? role;
  final String? language;
  final String? units;
  final String? theme;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    UserRole? role,
    String? language,
    String? units,
    String? theme,
  }) {
    return Profile(
      role: role ?? this.role,
      language: language ?? this.language,
      units: units ?? this.units,
      theme: theme ?? this.theme,
    );
  }
}

/// XP model for tracking experience points and levels
@JsonSerializable()
class XP {
  const XP({
    required this.total,
    required this.level,
    required this.lastRewards,
  });

  final int total;
  final int level;
  final List<String> lastRewards;

  factory XP.fromJson(Map<String, dynamic> json) => _$XPFromJson(json);
  Map<String, dynamic> toJson() => _$XPToJson(this);

  XP copyWith({
    int? total,
    int? level,
    List<String>? lastRewards,
  }) {
    return XP(
      total: total ?? this.total,
      level: level ?? this.level,
      lastRewards: lastRewards ?? this.lastRewards,
    );
  }
}

/// Extra item model representing bonus content like express workouts, challenges, etc.
@JsonSerializable()
class ExtraItem {
  const ExtraItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.duration,
    required this.blocks,
    this.difficulty,
  });

  final String id;
  final String title;
  final String description;
  final ExtraType type;
  final int xpReward;
  final int duration; // in minutes
  @JsonKey(fromJson: _blocksFromJson, toJson: _blocksToJson)
  final List<ExerciseBlock> blocks;
  final String? difficulty; // 'easy', 'medium', 'hard'

  factory ExtraItem.fromJson(Map<String, dynamic> json) =>
      _$ExtraItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraItemToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<ExerciseBlock> _blocksFromJson(List<dynamic> json) => json
      .map((e) => ExerciseBlock.fromJson(e as Map<String, dynamic>))
      .toList();

  static List<Map<String, dynamic>> _blocksToJson(List<ExerciseBlock> blocks) =>
      blocks.map((e) => e.toJson()).toList();
}

/// Performance analytics model for tracking progress across exercise categories
@JsonSerializable()
class PerformanceAnalytics {
  const PerformanceAnalytics({
    required this.categoryProgress,
    required this.weeklyStats,
    required this.streakData,
    required this.personalBests,
    required this.intensityTrends,
    required this.lastUpdated,
  });

  /// Progress percentage per exercise category (0.0 to 1.0)
  final Map<ExerciseCategory, double> categoryProgress;

  /// Weekly training statistics
  @JsonKey(fromJson: _weeklyStatsFromJson, toJson: _weeklyStatsToJson)
  final WeeklyStats weeklyStats;

  /// Streak information
  @JsonKey(fromJson: _streakDataFromJson, toJson: _streakDataToJson)
  final StreakData streakData;

  /// Personal bests for specific exercises
  @JsonKey(fromJson: _personalBestsFromJson, toJson: _personalBestsToJson)
  final Map<String, PersonalBest> personalBests;

  /// Training intensity trends over time
  @JsonKey(fromJson: _intensityTrendsFromJson, toJson: _intensityTrendsToJson)
  final List<IntensityDataPoint> intensityTrends;

  /// Last time analytics were calculated
  final DateTime lastUpdated;

  factory PerformanceAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PerformanceAnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceAnalyticsToJson(this);

  PerformanceAnalytics copyWith({
    Map<ExerciseCategory, double>? categoryProgress,
    WeeklyStats? weeklyStats,
    StreakData? streakData,
    Map<String, PersonalBest>? personalBests,
    List<IntensityDataPoint>? intensityTrends,
    DateTime? lastUpdated,
  }) {
    return PerformanceAnalytics(
      categoryProgress: categoryProgress ?? this.categoryProgress,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      streakData: streakData ?? this.streakData,
      personalBests: personalBests ?? this.personalBests,
      intensityTrends: intensityTrends ?? this.intensityTrends,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Custom serialization helpers for nested objects
  static WeeklyStats _weeklyStatsFromJson(Map<String, dynamic> json) =>
      WeeklyStats.fromJson(json);

  static Map<String, dynamic> _weeklyStatsToJson(WeeklyStats stats) =>
      stats.toJson();

  static StreakData _streakDataFromJson(Map<String, dynamic> json) =>
      StreakData.fromJson(json);

  static Map<String, dynamic> _streakDataToJson(StreakData data) =>
      data.toJson();

  static Map<String, PersonalBest> _personalBestsFromJson(
          Map<String, dynamic> json) =>
      json.map((k, e) =>
          MapEntry(k, PersonalBest.fromJson(e as Map<String, dynamic>)));

  static Map<String, dynamic> _personalBestsToJson(
          Map<String, PersonalBest> bests) =>
      bests.map((k, e) => MapEntry(k, e.toJson()));

  static List<IntensityDataPoint> _intensityTrendsFromJson(
          List<dynamic> json) =>
      json
          .map((e) => IntensityDataPoint.fromJson(e as Map<String, dynamic>))
          .toList();

  static List<Map<String, dynamic>> _intensityTrendsToJson(
          List<IntensityDataPoint> trends) =>
      trends.map((e) => e.toJson()).toList();
}

/// Weekly training statistics
@JsonSerializable()
class WeeklyStats {
  const WeeklyStats({
    required this.totalSessions,
    required this.totalExercises,
    required this.totalTrainingTime,
    required this.avgSessionDuration,
    required this.completionRate,
    required this.xpEarned,
  });

  final int totalSessions;
  final int totalExercises;
  final int totalTrainingTime; // in minutes
  final double avgSessionDuration; // in minutes
  final double completionRate; // 0.0 to 1.0
  final int xpEarned;

  factory WeeklyStats.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatsFromJson(json);
  Map<String, dynamic> toJson() => _$WeeklyStatsToJson(this);
}

/// Streak data for tracking consistency
@JsonSerializable()
class StreakData {
  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyGoal,
    required this.weeklyProgress,
    required this.lastTrainingDate,
  });

  final int currentStreak; // days
  final int longestStreak; // days
  final int weeklyGoal; // sessions per week
  final int weeklyProgress; // sessions completed this week
  final DateTime? lastTrainingDate;

  factory StreakData.fromJson(Map<String, dynamic> json) =>
      _$StreakDataFromJson(json);
  Map<String, dynamic> toJson() => _$StreakDataToJson(this);
}

/// Personal best record for an exercise
@JsonSerializable()
class PersonalBest {
  const PersonalBest({
    required this.exerciseId,
    required this.exerciseName,
    required this.bestValue,
    required this.unit,
    required this.achievedAt,
    required this.programId,
  });

  final String exerciseId;
  final String exerciseName;
  final double bestValue; // weight, reps, time, etc.
  final String unit; // 'kg', 'reps', 'seconds', etc.
  final DateTime achievedAt;
  final String programId;

  factory PersonalBest.fromJson(Map<String, dynamic> json) =>
      _$PersonalBestFromJson(json);
  Map<String, dynamic> toJson() => _$PersonalBestToJson(this);
}

/// Intensity data point for tracking training load over time
@JsonSerializable()
class IntensityDataPoint {
  const IntensityDataPoint({
    required this.date,
    required this.intensity,
    required this.volume,
    required this.duration,
  });

  final DateTime date;
  final double intensity; // 1.0 to 10.0 scale
  final int volume; // total exercises completed
  final int duration; // session duration in minutes

  factory IntensityDataPoint.fromJson(Map<String, dynamic> json) =>
      _$IntensityDataPointFromJson(json);
  Map<String, dynamic> toJson() => _$IntensityDataPointToJson(this);
}

/// Single set performance data
@JsonSerializable()
class ExerciseSetPerformance {
  const ExerciseSetPerformance({
    required this.setNumber,
    required this.reps,
    this.weight,
    this.completed,
    this.notes,
  });

  final int setNumber; // 1, 2, 3, etc.
  final int reps; // actual reps performed
  final double? weight; // weight used (in kg or lbs)
  final bool? completed; // whether this set was completed
  final String? notes; // optional notes for this set

  factory ExerciseSetPerformance.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseSetPerformanceToJson(this);

  ExerciseSetPerformance copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    bool? completed,
    String? notes,
  }) {
    return ExerciseSetPerformance(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }
}

/// Complete exercise performance for a single exercise in a session
@JsonSerializable()
class ExercisePerformance {
  const ExercisePerformance({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.programId,
    required this.week,
    required this.session,
    required this.timestamp,
    required this.sets,
    this.duration,
    this.notes,
  });

  final String id; // unique ID for this performance record
  final String exerciseId;
  final String exerciseName;
  final String programId;
  final int week;
  final int session;
  final DateTime timestamp;
  @JsonKey(fromJson: _setsFromJson, toJson: _setsToJson)
  final List<ExerciseSetPerformance> sets;
  final int? duration; // total time spent on exercise in seconds
  final String? notes; // overall notes for this exercise

  factory ExercisePerformance.fromJson(Map<String, dynamic> json) =>
      _$ExercisePerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$ExercisePerformanceToJson(this);

  ExercisePerformance copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    String? programId,
    int? week,
    int? session,
    DateTime? timestamp,
    List<ExerciseSetPerformance>? sets,
    int? duration,
    String? notes,
  }) {
    return ExercisePerformance(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      programId: programId ?? this.programId,
      week: week ?? this.week,
      session: session ?? this.session,
      timestamp: timestamp ?? this.timestamp,
      sets: sets ?? this.sets,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }

  static List<ExerciseSetPerformance> _setsFromJson(List<dynamic> json) => json
      .map((e) => ExerciseSetPerformance.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  static List<Map<String, dynamic>> _setsToJson(
          List<ExerciseSetPerformance> sets) =>
      sets.map((e) => e.toJson()).toList();
}
