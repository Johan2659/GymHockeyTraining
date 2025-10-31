/// Example usage of domain models with JSON serialization for Hive storage
library;

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Example service showing how to store/retrieve models as JSON strings in Hive
class ExampleStorageService {
  static const String _profileKey = 'user_profile';
  static const String _programStateKey = 'program_state';
  static const String _xpKey = 'user_xp';

  late Box<Map<dynamic, dynamic>> _profileBox;
  late Box<Map<dynamic, dynamic>> _programStateBox;
  late Box<Map<dynamic, dynamic>> _progressEventsBox;

  void initialize() {
    _profileBox = Hive.box<Map<dynamic, dynamic>>('profile');
    _programStateBox = Hive.box<Map<dynamic, dynamic>>('program_state');
    _progressEventsBox = Hive.box<Map<dynamic, dynamic>>('progress_events');
  }

  /// Save profile as JSON string in Hive
  Future<void> saveProfile(Profile profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await _profileBox.put(_profileKey, {'data': jsonString});
  }

  /// Load profile from JSON string in Hive
  Future<Profile?> loadProfile() async {
    final data = _profileBox.get(_profileKey);
    if (data == null || data['data'] == null) return null;

    final jsonString = data['data'] as String;
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    return Profile.fromJson(jsonData);
  }

  /// Save program state as JSON string in Hive
  Future<void> saveProgramState(ProgramState state) async {
    final jsonString = jsonEncode(state.toJson());
    await _programStateBox.put(_programStateKey, {'data': jsonString});
  }

  /// Load program state from JSON string in Hive
  Future<ProgramState?> loadProgramState() async {
    final data = _programStateBox.get(_programStateKey);
    if (data == null || data['data'] == null) return null;

    final jsonString = data['data'] as String;
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    return ProgramState.fromJson(jsonData);
  }

  /// Save XP as JSON string in Hive
  Future<void> saveXP(XP xp) async {
    final jsonString = jsonEncode(xp.toJson());
    await _profileBox.put(_xpKey, {'data': jsonString});
  }

  /// Load XP from JSON string in Hive
  Future<XP?> loadXP() async {
    final data = _profileBox.get(_xpKey);
    if (data == null || data['data'] == null) return null;

    final jsonString = data['data'] as String;
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    return XP.fromJson(jsonData);
  }

  /// Save progress event as JSON string in Hive (with timestamp as key)
  Future<void> saveProgressEvent(ProgressEvent event) async {
    final jsonString = jsonEncode(event.toJson());
    final key = event.ts.millisecondsSinceEpoch.toString();
    await _progressEventsBox.put(key, {'data': jsonString});
  }

  /// Load all progress events from Hive
  Future<List<ProgressEvent>> loadProgressEvents() async {
    final events = <ProgressEvent>[];

    for (final value in _progressEventsBox.values) {
      if (value['data'] != null) {
        final jsonString = value['data'] as String;
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        events.add(ProgressEvent.fromJson(jsonData));
      }
    }

    // Sort by timestamp
    events.sort((a, b) => a.ts.compareTo(b.ts));
    return events;
  }

  /// Example of creating sample data
  static ProgressEvent createSampleProgressEvent() {
    return ProgressEvent(
      ts: DateTime.now(),
      type: ProgressEventType.sessionStarted,
      programId: 'attacker_program_1',
      week: 1,
      session: 1,
      exerciseId: 'push_ups_1',
      payload: {
        'sets_completed': 0,
        'reps_completed': 0,
        'start_time': DateTime.now().toIso8601String(),
      },
    );
  }

  static Profile createSampleProfile() {
    return const Profile(
      role: UserRole.attacker,
      language: 'en',
      units: 'metric',
      theme: 'dark',
    );
  }

  static ProgramState createSampleProgramState() {
    return const ProgramState(
      activeProgramId: 'attacker_program_1',
      currentWeek: 1,
      currentSession: 1,
      completedExerciseIds: ['warm_up_1', 'stretch_1'],
    );
  }

  static XP createSampleXP() {
    return const XP(
      total: 150,
      level: 3,
      lastRewards: ['First Session Complete', 'Week 1 Milestone'],
    );
  }
}
