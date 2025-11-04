import 'dart:convert';
import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';

/// Comprehensive Referee program - 5 weeks, 3 sessions per week
/// Focuses on conditioning, mobility, and decision-making under fatigue
class RefereeProgramData {
  static final _logger = AppLogger.getLogger();

  // =============================================================================
  // WEEK 1-2 SESSIONS (Conditioning Focus)
  // =============================================================================

  static const String _week1Session1 = '''
{
  "id": "referee_w1_s1",
  "title": "Speed + Decision Making",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "sprint_10m"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week1Session2 = '''
{
  "id": "referee_w1_s2",
  "title": "Endurance + Mobility",
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

  static const String _week1Session3 = '''
{
  "id": "referee_w1_s3",
  "title": "Agility + Recovery",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "five_ten_five_shuttle"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  // Weeks 2-5 sessions follow same pattern...
  // For brevity, only showing the program definition

  static const String _refereeProgram = '''
{
  "id": "hockey_referee_2025",
  "role": "referee",
  "title": "🧑‍⚖️ Referee - 5 Weeks (World-Class)",
  "weeks": [
    {
      "index": 0,
      "sessions": ["referee_w1_s1", "referee_w1_s2", "referee_w1_s3"]
    },
    {
      "index": 1,
      "sessions": ["referee_w2_s1", "referee_w2_s2", "referee_w2_s3"]
    },
    {
      "index": 2,
      "sessions": ["referee_w3_s1", "referee_w3_s2", "referee_w3_s3"]
    },
    {
      "index": 3,
      "sessions": ["referee_w4_s1", "referee_w4_s2", "referee_w4_s3"]
    },
    {
      "index": 4,
      "sessions": ["referee_w5_s1", "referee_w5_s2", "referee_w5_s3"]
    }
  ]
}
''';

  /// Gets the complete referee program
  static Future<Program?> getRefereeProgram() async {
    try {
      final programJson = jsonDecode(_refereeProgram);
      return Program.fromJson(programJson);
    } catch (e, stack) {
      _logger.e('Error parsing referee program', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Gets all sessions for the referee program
  static Future<List<Session>> getAllSessions() async {
    try {
      final sessions = <Session>[];

      // Week 1 sessions
      final week1Sessions = [
        await _loadSession('referee_w1_s1', _week1Session1),
        await _loadSession('referee_w1_s2', _week1Session2),
        await _loadSession('referee_w1_s3', _week1Session3),
      ];
      sessions.addAll(week1Sessions.whereType<Session>());

      // Add other weeks when defined...

      return sessions;
    } catch (e, stack) {
      _logger.e('Error getting referee sessions', error: e, stackTrace: stack);
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
        'referee_w1_s1': _week1Session1,
        'referee_w1_s2': _week1Session2,
        'referee_w1_s3': _week1Session3,
      };

      final jsonString = sessionMap[id];
      if (jsonString == null) {
        _logger.w('Session not found: $id');
        return null;
      }

      return await _loadSession(id, jsonString);
    } catch (e, stack) {
      _logger.e('Error getting referee session $id',
          error: e, stackTrace: stack);
      return null;
    }
  }
}
