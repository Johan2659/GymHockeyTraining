// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
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
      'category': instance.category,
      'sets': instance.sets,
      'reps': instance.reps,
      'duration': instance.duration,
      'rest': instance.rest,
      'youtubeQuery': instance.youtubeQuery,
      'gymAltId': instance.gymAltId,
      'homeAltId': instance.homeAltId,
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
