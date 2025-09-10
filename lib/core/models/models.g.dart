// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$ExerciseCategoryEnumMap, json['category']),
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      rest: (json['rest'] as num?)?.toInt(),
      youtubeQuery: json['youtubeQuery'] as String,
      gymAltId: json['gymAltId'] as String?,
      homeAltId: json['homeAltId'] as String?,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': _$ExerciseCategoryEnumMap[instance.category]!,
      'sets': instance.sets,
      'reps': instance.reps,
      'duration': instance.duration,
      'rest': instance.rest,
      'youtubeQuery': instance.youtubeQuery,
      'gymAltId': instance.gymAltId,
      'homeAltId': instance.homeAltId,
    };

const _$ExerciseCategoryEnumMap = {
  ExerciseCategory.strength: 'strength',
  ExerciseCategory.power: 'power',
  ExerciseCategory.speed: 'speed',
  ExerciseCategory.agility: 'agility',
  ExerciseCategory.conditioning: 'conditioning',
  ExerciseCategory.technique: 'technique',
  ExerciseCategory.balance: 'balance',
  ExerciseCategory.flexibility: 'flexibility',
  ExerciseCategory.warmup: 'warmup',
  ExerciseCategory.recovery: 'recovery',
  ExerciseCategory.stickSkills: 'stick_skills',
  ExerciseCategory.gameSituation: 'game_situation',
};

ExerciseBlock _$ExerciseBlockFromJson(Map<String, dynamic> json) =>
    ExerciseBlock(
      exerciseId: json['exerciseId'] as String,
      swapGymId: json['swapGymId'] as String?,
      swapHomeId: json['swapHomeId'] as String?,
    );

Map<String, dynamic> _$ExerciseBlockToJson(ExerciseBlock instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'swapGymId': instance.swapGymId,
      'swapHomeId': instance.swapHomeId,
    };

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
      id: json['id'] as String,
      title: json['title'] as String,
      blocks: Session._blocksFromJson(json['blocks'] as List),
      bonusChallenge: json['bonusChallenge'] as String,
    );

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'blocks': Session._blocksToJson(instance.blocks),
      'bonusChallenge': instance.bonusChallenge,
    };

Week _$WeekFromJson(Map<String, dynamic> json) => Week(
      index: (json['index'] as num).toInt(),
      sessions:
          (json['sessions'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$WeekToJson(Week instance) => <String, dynamic>{
      'index': instance.index,
      'sessions': instance.sessions,
    };

Program _$ProgramFromJson(Map<String, dynamic> json) => Program(
      id: json['id'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      title: json['title'] as String,
      weeks: Program._weeksFromJson(json['weeks'] as List),
    );

Map<String, dynamic> _$ProgramToJson(Program instance) => <String, dynamic>{
      'id': instance.id,
      'role': _$UserRoleEnumMap[instance.role]!,
      'title': instance.title,
      'weeks': Program._weeksToJson(instance.weeks),
    };

const _$UserRoleEnumMap = {
  UserRole.attacker: 'attacker',
  UserRole.defender: 'defender',
  UserRole.goalie: 'goalie',
  UserRole.referee: 'referee',
};

ProgramState _$ProgramStateFromJson(Map<String, dynamic> json) => ProgramState(
      activeProgramId: json['activeProgramId'] as String?,
      currentWeek: (json['currentWeek'] as num).toInt(),
      currentSession: (json['currentSession'] as num).toInt(),
      completedExerciseIds: (json['completedExerciseIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      pausedAt: json['pausedAt'] == null
          ? null
          : DateTime.parse(json['pausedAt'] as String),
    );

Map<String, dynamic> _$ProgramStateToJson(ProgramState instance) =>
    <String, dynamic>{
      'activeProgramId': instance.activeProgramId,
      'currentWeek': instance.currentWeek,
      'currentSession': instance.currentSession,
      'completedExerciseIds': instance.completedExerciseIds,
      'pausedAt': instance.pausedAt?.toIso8601String(),
    };

ProgressEvent _$ProgressEventFromJson(Map<String, dynamic> json) =>
    ProgressEvent(
      ts: DateTime.parse(json['ts'] as String),
      type: $enumDecode(_$ProgressEventTypeEnumMap, json['type']),
      programId: json['programId'] as String,
      week: (json['week'] as num).toInt(),
      session: (json['session'] as num).toInt(),
      exerciseId: json['exerciseId'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProgressEventToJson(ProgressEvent instance) =>
    <String, dynamic>{
      'ts': instance.ts.toIso8601String(),
      'type': _$ProgressEventTypeEnumMap[instance.type]!,
      'programId': instance.programId,
      'week': instance.week,
      'session': instance.session,
      'exerciseId': instance.exerciseId,
      'payload': instance.payload,
    };

const _$ProgressEventTypeEnumMap = {
  ProgressEventType.sessionStarted: 'session_started',
  ProgressEventType.exerciseDone: 'exercise_done',
  ProgressEventType.sessionCompleted: 'session_completed',
  ProgressEventType.bonusDone: 'bonus_done',
  ProgressEventType.extraCompleted: 'extra_completed',
};

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
      language: json['language'] as String?,
      units: json['units'] as String?,
      theme: json['theme'] as String?,
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'role': _$UserRoleEnumMap[instance.role],
      'language': instance.language,
      'units': instance.units,
      'theme': instance.theme,
    };

XP _$XPFromJson(Map<String, dynamic> json) => XP(
      total: (json['total'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      lastRewards: (json['lastRewards'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$XPToJson(XP instance) => <String, dynamic>{
      'total': instance.total,
      'level': instance.level,
      'lastRewards': instance.lastRewards,
    };

ExtraItem _$ExtraItemFromJson(Map<String, dynamic> json) => ExtraItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ExtraTypeEnumMap, json['type']),
      xpReward: (json['xpReward'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      blocks: ExtraItem._blocksFromJson(json['blocks'] as List),
      difficulty: json['difficulty'] as String?,
    );

Map<String, dynamic> _$ExtraItemToJson(ExtraItem instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$ExtraTypeEnumMap[instance.type]!,
      'xpReward': instance.xpReward,
      'duration': instance.duration,
      'blocks': ExtraItem._blocksToJson(instance.blocks),
      'difficulty': instance.difficulty,
    };

const _$ExtraTypeEnumMap = {
  ExtraType.expressWorkout: 'express_workout',
  ExtraType.bonusChallenge: 'bonus_challenge',
  ExtraType.mobilityRecovery: 'mobility_recovery',
};

PerformanceAnalytics _$PerformanceAnalyticsFromJson(
        Map<String, dynamic> json) =>
    PerformanceAnalytics(
      categoryProgress: (json['categoryProgress'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$ExerciseCategoryEnumMap, k), (e as num).toDouble()),
      ),
      weeklyStats: PerformanceAnalytics._weeklyStatsFromJson(
          json['weeklyStats'] as Map<String, dynamic>),
      streakData: PerformanceAnalytics._streakDataFromJson(
          json['streakData'] as Map<String, dynamic>),
      personalBests: PerformanceAnalytics._personalBestsFromJson(
          json['personalBests'] as Map<String, dynamic>),
      intensityTrends: PerformanceAnalytics._intensityTrendsFromJson(
          json['intensityTrends'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$PerformanceAnalyticsToJson(
        PerformanceAnalytics instance) =>
    <String, dynamic>{
      'categoryProgress': instance.categoryProgress
          .map((k, e) => MapEntry(_$ExerciseCategoryEnumMap[k]!, e)),
      'weeklyStats':
          PerformanceAnalytics._weeklyStatsToJson(instance.weeklyStats),
      'streakData': PerformanceAnalytics._streakDataToJson(instance.streakData),
      'personalBests':
          PerformanceAnalytics._personalBestsToJson(instance.personalBests),
      'intensityTrends':
          PerformanceAnalytics._intensityTrendsToJson(instance.intensityTrends),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

WeeklyStats _$WeeklyStatsFromJson(Map<String, dynamic> json) => WeeklyStats(
      totalSessions: (json['totalSessions'] as num).toInt(),
      totalExercises: (json['totalExercises'] as num).toInt(),
      totalTrainingTime: (json['totalTrainingTime'] as num).toInt(),
      avgSessionDuration: (json['avgSessionDuration'] as num).toDouble(),
      completionRate: (json['completionRate'] as num).toDouble(),
      xpEarned: (json['xpEarned'] as num).toInt(),
    );

Map<String, dynamic> _$WeeklyStatsToJson(WeeklyStats instance) =>
    <String, dynamic>{
      'totalSessions': instance.totalSessions,
      'totalExercises': instance.totalExercises,
      'totalTrainingTime': instance.totalTrainingTime,
      'avgSessionDuration': instance.avgSessionDuration,
      'completionRate': instance.completionRate,
      'xpEarned': instance.xpEarned,
    };

StreakData _$StreakDataFromJson(Map<String, dynamic> json) => StreakData(
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      weeklyGoal: (json['weeklyGoal'] as num).toInt(),
      weeklyProgress: (json['weeklyProgress'] as num).toInt(),
      lastTrainingDate: json['lastTrainingDate'] == null
          ? null
          : DateTime.parse(json['lastTrainingDate'] as String),
    );

Map<String, dynamic> _$StreakDataToJson(StreakData instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'weeklyGoal': instance.weeklyGoal,
      'weeklyProgress': instance.weeklyProgress,
      'lastTrainingDate': instance.lastTrainingDate?.toIso8601String(),
    };

PersonalBest _$PersonalBestFromJson(Map<String, dynamic> json) => PersonalBest(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      bestValue: (json['bestValue'] as num).toDouble(),
      unit: json['unit'] as String,
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      programId: json['programId'] as String,
    );

Map<String, dynamic> _$PersonalBestToJson(PersonalBest instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'exerciseName': instance.exerciseName,
      'bestValue': instance.bestValue,
      'unit': instance.unit,
      'achievedAt': instance.achievedAt.toIso8601String(),
      'programId': instance.programId,
    };

IntensityDataPoint _$IntensityDataPointFromJson(Map<String, dynamic> json) =>
    IntensityDataPoint(
      date: DateTime.parse(json['date'] as String),
      intensity: (json['intensity'] as num).toDouble(),
      volume: (json['volume'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$IntensityDataPointToJson(IntensityDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'intensity': instance.intensity,
      'volume': instance.volume,
      'duration': instance.duration,
    };
