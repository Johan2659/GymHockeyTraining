import 'dart:convert';
import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import 'attacker_program_data.dart';

/// Local data source for sessions using embedded JSON data
/// Provides session definitions and exercise blocks
class LocalSessionSource {
  static final _logger = Logger();

  // Static session data for the hockey attacker program
  static const Map<String, String> _sessionData = {
    'week1_session1': '''
{
  "id": "week1_session1",
  "title": "Speed & Agility Foundations",
  "blocks": [
    {
      "exerciseId": "ex_warmup_skate",
      "swapGymId": "ex_warmup_jog",
      "swapHomeId": "ex_warmup_shadowbox"
    },
    {
      "exerciseId": "ex_cone_weaving"
    },
    {
      "exerciseId": "ex_sprint_intervals"
    },
    {
      "exerciseId": "ex_cooldown_stretch"
    }
  ],
  "bonusChallenge": "Complete 5 extra burpees for +10 XP"
}
''',
    'week1_session2': '''
{
  "id": "week1_session2",
  "title": "Stick Handling Drills",
  "blocks": [
    {
      "exerciseId": "ex_warmup_skate",
      "swapGymId": "ex_warmup_jog",
      "swapHomeId": "ex_warmup_shadowbox"
    },
    {
      "exerciseId": "ex_stick_handling_figure8"
    },
    {
      "exerciseId": "ex_shooting_accuracy"
    },
    {
      "exerciseId": "ex_cooldown_stretch"
    }
  ],
  "bonusChallenge": "Complete 20 extra stick taps for +15 XP"
}
''',
    'week1_session3': '''
{
  "id": "week1_session3",
  "title": "Power & Explosiveness",
  "blocks": [
    {
      "exerciseId": "ex_warmup_skate",
      "swapGymId": "ex_warmup_jog",
      "swapHomeId": "ex_warmup_shadowbox"
    },
    {
      "exerciseId": "ex_plyometric_jumps"
    },
    {
      "exerciseId": "ex_explosive_starts"
    },
    {
      "exerciseId": "ex_cooldown_stretch"
    }
  ],
  "bonusChallenge": "Complete 10 extra jump squats for +20 XP"
}
''',
    'week2_session1': '''
{
  "id": "week2_session1", 
  "title": "Advanced Speed Work",
  "blocks": [
    {
      "exerciseId": "ex_warmup_skate",
      "swapGymId": "ex_warmup_jog",
      "swapHomeId": "ex_warmup_shadowbox"
    },
    {
      "exerciseId": "ex_acceleration_drills"
    },
    {
      "exerciseId": "ex_direction_changes"
    },
    {
      "exerciseId": "ex_cooldown_stretch"
    }
  ],
  "bonusChallenge": "Complete the circuit twice for +25 XP"
}
''',
    'week2_session2': '''
{
  "id": "week2_session2",
  "title": "Stick Skills Advanced",
  "blocks": [
    {
      "exerciseId": "ex_warmup_skate",
      "swapGymId": "ex_warmup_jog", 
      "swapHomeId": "ex_warmup_shadowbox"
    },
    {
      "exerciseId": "ex_one_handed_control"
    },
    {
      "exerciseId": "ex_backhand_shots"
    },
    {
      "exerciseId": "ex_cooldown_stretch"
    }
  ],
  "bonusChallenge": "Score 8/10 accuracy shots for +30 XP"
}
''',
    'week2_session3': '''
{
  "id": "week2_session3",
  "title": "Game Simulation",
  "blocks": [
    {
      "exerciseId": "ex_warmup_skate",
      "swapGymId": "ex_warmup_jog",
      "swapHomeId": "ex_warmup_shadowbox"
    },
    {
      "exerciseId": "ex_breakaway_practice"
    },
    {
      "exerciseId": "ex_battle_drills"
    },
    {
      "exerciseId": "ex_cooldown_stretch"
    }
  ],
  "bonusChallenge": "Complete all drills at game speed for +35 XP"
}
'''
  };

  /// Gets all available sessions
  Future<List<Session>> getAllSessions() async {
    try {
      _logger.d('LocalSessionSource: Loading all sessions');

      final sessions = <Session>[];

      for (final entry in _sessionData.entries) {
        final session = await _loadSession(entry.key, entry.value);
        if (session != null) {
          sessions.add(session);
        }
      }

      _logger.i('LocalSessionSource: Loaded ${sessions.length} sessions');
      return sessions;
    } catch (e, stackTrace) {
      _logger.e('LocalSessionSource: Failed to load sessions',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific session by ID
  Future<Session?> getSessionById(String id) async {
    try {
      _logger.d('LocalSessionSource: Loading session with ID: $id');

      // Check if it's a new attacker program session
      if (id.startsWith('attacker_w')) {
        return await AttackerProgramData.getSessionById(id);
      }

      // Check legacy sessions
      final sessionJson = _sessionData[id];
      if (sessionJson == null) {
        _logger.w('LocalSessionSource: Session not found: $id');
        return null;
      }

      return await _loadSession(id, sessionJson);
    } catch (e, stackTrace) {
      _logger.e('LocalSessionSource: Failed to load session $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Gets sessions for a specific program
  Future<List<Session>> getSessionsByProgramId(String programId) async {
    try {
      _logger.d('LocalSessionSource: Loading sessions for program: $programId');

      // Handle new attacker program
      if (programId == 'hockey_attacker_2025') {
        return await AttackerProgramData.getAllSessions();
      }

      // Legacy attacker program
      if (programId == 'hockey_attacker_v1') {
        return await getAllSessions();
      }

      _logger
          .w('LocalSessionSource: No sessions found for program: $programId');
      return [];
    } catch (e, stackTrace) {
      _logger.e(
          'LocalSessionSource: Failed to load sessions for program $programId',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets sessions for a specific week in a program
  Future<List<Session>> getSessionsByWeek(String programId, int week) async {
    try {
      _logger.d(
          'LocalSessionSource: Loading sessions for program $programId, week $week');

      final allSessions = await getSessionsByProgramId(programId);
      
      // For new attacker program, filter by attacker_w{week}_
      if (programId == 'hockey_attacker_2025') {
        final weekNum = week + 1; // Convert 0-based to 1-based
        final weekSessions = allSessions
            .where((session) => session.id.startsWith('attacker_w${weekNum}_'))
            .toList();

        _logger.d(
            'LocalSessionSource: Found ${weekSessions.length} sessions for week $week');
        return weekSessions;
      }

      // Legacy format for old program
      final weekSessions = allSessions
          .where((session) => session.id.startsWith('week${week}_'))
          .toList();

      _logger.d(
          'LocalSessionSource: Found ${weekSessions.length} sessions for week $week');
      return weekSessions;
    } catch (e, stackTrace) {
      _logger.e('LocalSessionSource: Failed to load sessions for week $week',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Loads a session from JSON string
  Future<Session?> _loadSession(String id, String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final session = Session.fromJson(jsonData);

      _logger.d(
          'LocalSessionSource: Successfully loaded session: ${session.title}');
      return session;
    } catch (e, stackTrace) {
      _logger.e('LocalSessionSource: Failed to parse session JSON for $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
