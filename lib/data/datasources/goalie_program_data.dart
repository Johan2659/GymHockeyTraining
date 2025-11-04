import 'dart:convert';
import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';

/// Comprehensive Goalie program - 5 weeks, 3 sessions per week
/// Focuses on reflexes, flexibility, and explosive power
class GoalieProgramData {
  static final _logger = AppLogger.getLogger();

  // =============================================================================
  // WEEK 1-2 SESSIONS (Foundation Focus)
  // =============================================================================

  static const String _week1Session1 = '''
{
  "id": "goalie_w1_s1",
  "title": "Reflexes + Lower Body",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "t_test"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week1Session2 = '''
{
  "id": "goalie_w1_s2",
  "title": "Flexibility + Core Power",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "side_plank_reach"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week1Session3 = '''
{
  "id": "goalie_w1_s3",
  "title": "Explosive Movement + Balance",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "skater_bounds"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  // Weeks 2-5 sessions follow same pattern...
  // For brevity, only showing the program definition

  static const String _goalieProgram = '''
{
  "id": "hockey_goalie_2025",
  "role": "goalie",
  "title": "🧤 Goalie - 5 Weeks (World-Class)",
  "weeks": [
    {
      "index": 0,
      "sessions": ["goalie_w1_s1", "goalie_w1_s2", "goalie_w1_s3"]
    },
    {
      "index": 1,
      "sessions": ["goalie_w2_s1", "goalie_w2_s2", "goalie_w2_s3"]
    },
    {
      "index": 2,
      "sessions": ["goalie_w3_s1", "goalie_w3_s2", "goalie_w3_s3"]
    },
    {
      "index": 3,
      "sessions": ["goalie_w4_s1", "goalie_w4_s2", "goalie_w4_s3"]
    },
    {
      "index": 4,
      "sessions": ["goalie_w5_s1", "goalie_w5_s2", "goalie_w5_s3"]
    }
  ]
}
''';

  /// Gets the complete goalie program
  static Future<Program?> getGoalieProgram() async {
    try {
      final programJson = jsonDecode(_goalieProgram);
      return Program.fromJson(programJson);
    } catch (e, stack) {
      _logger.e('Error parsing goalie program', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Gets all sessions for the goalie program
  static Future<List<Session>> getAllSessions() async {
    try {
      final sessions = <Session>[];

      // Week 1 sessions
      final week1Sessions = [
        await _loadSession('goalie_w1_s1', _week1Session1),
        await _loadSession('goalie_w1_s2', _week1Session2),
        await _loadSession('goalie_w1_s3', _week1Session3),
      ];
      sessions.addAll(week1Sessions.whereType<Session>());

      // Add other weeks when defined...

      return sessions;
    } catch (e, stack) {
      _logger.e('Error getting goalie sessions', error: e, stackTrace: stack);
      return [];
    }
  }

  /// Loads a session from JSON string
  static Future<Session?> _loadSession(String id, String jsonString) async {
    try {
      final sessionJson = jsonDecode(jsonString);
      return Session.fromJson(sessionJson);
    } catch (e, stack) {
      _logger.e('Error loading session $id', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Gets a specific session by ID
  static Future<Session?> getSessionById(String id) async {
    try {
      // Map of session IDs to their JSON strings
      final sessionMap = {
        'goalie_w1_s1': _week1Session1,
        'goalie_w1_s2': _week1Session2,
        'goalie_w1_s3': _week1Session3,
      };

      final jsonString = sessionMap[id];
      if (jsonString == null) {
        _logger.w('Session not found: $id');
        return null;
      }

      return await _loadSession(id, jsonString);
    } catch (e, stack) {
      _logger.e('Error getting goalie session $id',
          error: e, stackTrace: stack);
      return null;
    }
  }
}
