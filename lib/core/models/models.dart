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
  });

  final String id;
  final String name;
  final String category;
  final int sets;
  final int reps;
  final int? duration; // in seconds
  final int? rest; // in seconds
  final String youtubeQuery;
  final String? gymAltId;
  final String? homeAltId;

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
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

  factory ExerciseBlock.fromJson(Map<String, dynamic> json) => _$ExerciseBlockFromJson(json);
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

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
  Map<String, dynamic> toJson() => _$SessionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<ExerciseBlock> _blocksFromJson(List<dynamic> json) =>
      json.map((e) => ExerciseBlock.fromJson(e as Map<String, dynamic>)).toList();

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

  factory Program.fromJson(Map<String, dynamic> json) => _$ProgramFromJson(json);
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

/// Program state model for tracking user progress in a program
@JsonSerializable()
class ProgramState {
  const ProgramState({
    this.activeProgramId,
    required this.currentWeek,
    required this.currentSession,
    required this.completedExerciseIds,
    this.pausedAt,
  });

  final String? activeProgramId;
  final int currentWeek;
  final int currentSession;
  final List<String> completedExerciseIds;
  final DateTime? pausedAt;

  factory ProgramState.fromJson(Map<String, dynamic> json) => _$ProgramStateFromJson(json);
  Map<String, dynamic> toJson() => _$ProgramStateToJson(this);

  ProgramState copyWith({
    String? activeProgramId,
    int? currentWeek,
    int? currentSession,
    List<String>? completedExerciseIds,
    DateTime? pausedAt,
  }) {
    return ProgramState(
      activeProgramId: activeProgramId ?? this.activeProgramId,
      currentWeek: currentWeek ?? this.currentWeek,
      currentSession: currentSession ?? this.currentSession,
      completedExerciseIds: completedExerciseIds ?? this.completedExerciseIds,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }
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

  factory ProgressEvent.fromJson(Map<String, dynamic> json) => _$ProgressEventFromJson(json);
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

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
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

  factory ExtraItem.fromJson(Map<String, dynamic> json) => _$ExtraItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraItemToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtraItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<ExerciseBlock> _blocksFromJson(List<dynamic> json) =>
      json.map((e) => ExerciseBlock.fromJson(e as Map<String, dynamic>)).toList();

  static List<Map<String, dynamic>> _blocksToJson(List<ExerciseBlock> blocks) =>
      blocks.map((e) => e.toJson()).toList();
}
