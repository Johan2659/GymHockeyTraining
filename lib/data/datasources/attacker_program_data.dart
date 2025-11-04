import 'dart:convert';
import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';

/// Comprehensive Attacker program - 5 weeks, 3 sessions per week
/// Follows the specified structure with strength focus, hypertrophy, and power phases
class AttackerProgramData {
  static final _logger = AppLogger.getLogger();

  // =============================================================================
  // WEEK 1-2 SESSIONS (Strength Focus)
  // =============================================================================

  static const String _week1Session1 = '''
{
  "id": "attacker_w1_s1",
  "title": "Lower Dominante + Rotation",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "skater_bounds"
    },
    {
      "exerciseId": "back_squat",
      "swapGymId": "goblet_squat",
      "swapHomeId": "jump_squat"
    },
    {
      "exerciseId": "walking_lunge",
      "swapGymId": "split_squat",
      "swapHomeId": "bodyweight_lunge"
    },
    {
      "exerciseId": "barbell_row",
      "swapGymId": "chest_supported_row",
      "swapHomeId": "backpack_row_table"
    },
    {
      "exerciseId": "pallof_press_rotation",
      "swapGymId": "cable_rotation",
      "swapHomeId": "resistance_band_rotation"
    },
    {
      "exerciseId": "bike_intervals_20_40",
      "swapHomeId": "high_knees_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week1Session2 = '''
{
  "id": "attacker_w1_s2",
  "title": "Posterior Chain + Push Équilibré",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "sprint_10m"
    },
    {
      "exerciseId": "deadlift",
      "swapGymId": "hip_thrust",
      "swapHomeId": "hip_hinge_backpack"
    },
    {
      "exerciseId": "bench_press",
      "swapGymId": "dumbbell_bench",
      "swapHomeId": "push_ups_weighted"
    },
    {
      "exerciseId": "weighted_pull_ups",
      "swapGymId": "lat_pulldown",
      "swapHomeId": "towel_door_rows"
    },
    {
      "exerciseId": "nordic_hamstring",
      "swapGymId": "leg_curl",
      "swapHomeId": "hamstring_curl_towel"
    },
    {
      "exerciseId": "bike_intervals_15_45",
      "swapHomeId": "burpee_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week1Session3 = '''
{
  "id": "attacker_w1_s3",
  "title": "Unilatéral + Adducteurs + Tir",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "five_ten_five_shuttle"
    },
    {
      "exerciseId": "front_squat",
      "swapGymId": "split_squat_heavy",
      "swapHomeId": "pistol_squat_assist"
    },
    {
      "exerciseId": "landmine_press",
      "swapGymId": "dumbbell_incline_unilateral",
      "swapHomeId": "single_arm_push_up"
    },
    {
      "exerciseId": "one_arm_row",
      "swapHomeId": "backpack_row"
    },
    {
      "exerciseId": "copenhagen_plank",
      "swapGymId": "adductor_squeeze"
    },
    {
      "exerciseId": "medicine_ball_side_throw",
      "swapHomeId": "jump_rotation_arms"
    },
    {
      "exerciseId": "bike_intervals_20_40",
      "swapHomeId": "high_knees_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  // Week 2 - Same structure with progression
  static const String _week2Session1 = '''
{
  "id": "attacker_w2_s1",
  "title": "Lower Dominante + Rotation (Week 2)",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "skater_bounds"
    },
    {
      "exerciseId": "back_squat",
      "swapGymId": "goblet_squat",
      "swapHomeId": "jump_squat"
    },
    {
      "exerciseId": "walking_lunge",
      "swapGymId": "split_squat",
      "swapHomeId": "bodyweight_lunge"
    },
    {
      "exerciseId": "barbell_row",
      "swapGymId": "chest_supported_row",
      "swapHomeId": "backpack_row_table"
    },
    {
      "exerciseId": "pallof_press_rotation",
      "swapGymId": "cable_rotation",
      "swapHomeId": "resistance_band_rotation"
    },
    {
      "exerciseId": "bike_intervals_20_40",
      "swapHomeId": "high_knees_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week2Session2 = '''
{
  "id": "attacker_w2_s2",
  "title": "Posterior Chain + Push Équilibré (Week 2)",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "sprint_10m"
    },
    {
      "exerciseId": "deadlift",
      "swapGymId": "hip_thrust",
      "swapHomeId": "hip_hinge_backpack"
    },
    {
      "exerciseId": "bench_press",
      "swapGymId": "dumbbell_bench",
      "swapHomeId": "push_ups_weighted"
    },
    {
      "exerciseId": "weighted_pull_ups",
      "swapGymId": "lat_pulldown",
      "swapHomeId": "towel_door_rows"
    },
    {
      "exerciseId": "nordic_hamstring",
      "swapGymId": "leg_curl",
      "swapHomeId": "hamstring_curl_towel"
    },
    {
      "exerciseId": "bike_intervals_15_45",
      "swapHomeId": "burpee_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week2Session3 = '''
{
  "id": "attacker_w2_s3",
  "title": "Unilatéral + Adducteurs + Tir (Week 2)",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "five_ten_five_shuttle"
    },
    {
      "exerciseId": "front_squat",
      "swapGymId": "split_squat_heavy",
      "swapHomeId": "pistol_squat_assist"
    },
    {
      "exerciseId": "landmine_press",
      "swapGymId": "dumbbell_incline_unilateral",
      "swapHomeId": "single_arm_push_up"
    },
    {
      "exerciseId": "one_arm_row",
      "swapHomeId": "backpack_row"
    },
    {
      "exerciseId": "copenhagen_plank",
      "swapGymId": "adductor_squeeze"
    },
    {
      "exerciseId": "medicine_ball_side_throw",
      "swapHomeId": "jump_rotation_arms"
    },
    {
      "exerciseId": "bike_intervals_20_40",
      "swapHomeId": "high_knees_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  // =============================================================================
  // WEEK 3-4 SESSIONS (Hypertrophy/Capacity Focus)
  // =============================================================================

  static const String _week3Session1 = '''
{
  "id": "attacker_w3_s1",
  "title": "Quadriceps + Pull > Push",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "skater_bounds"
    },
    {
      "exerciseId": "back_squat",
      "swapGymId": "goblet_squat",
      "swapHomeId": "bodyweight_squat"
    },
    {
      "exerciseId": "bulgarian_split_squat",
      "swapHomeId": "reverse_lunge"
    },
    {
      "exerciseId": "dumbbell_bench",
      "swapHomeId": "push_ups_decline"
    },
    {
      "exerciseId": "chest_supported_row",
      "swapHomeId": "resistance_band_rows"
    },
    {
      "exerciseId": "side_plank_reach"
    },
    {
      "exerciseId": "bike_intervals_30_30",
      "swapHomeId": "mountain_climber_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week3Session2 = '''
{
  "id": "attacker_w3_s2",
  "title": "Posterior + Épaules Saines",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "crossovers_off_ice"
    },
    {
      "exerciseId": "hip_thrust",
      "swapGymId": "romanian_deadlift",
      "swapHomeId": "single_leg_glute_bridge"
    },
    {
      "exerciseId": "lat_pulldown",
      "swapHomeId": "resistance_band_rows"
    },
    {
      "exerciseId": "arnold_press",
      "swapHomeId": "pike_push_ups"
    },
    {
      "exerciseId": "nordic_hamstring",
      "swapHomeId": "hamstring_curl_towel"
    },
    {
      "exerciseId": "face_pulls",
      "swapHomeId": "ytw_raises"
    },
    {
      "exerciseId": "pallof_press",
      "swapHomeId": "pallof_resistance_band"
    },
    {
      "exerciseId": "bike_intervals_20_40",
      "swapHomeId": "high_knees_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week3Session3 = '''
{
  "id": "attacker_w3_s3",
  "title": "Unilatéral + Rotation + Mollets",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "t_test"
    },
    {
      "exerciseId": "step_up",
      "swapHomeId": "stair_step_up"
    },
    {
      "exerciseId": "bulgarian_split_squat",
      "swapHomeId": "reverse_lunge"
    },
    {
      "exerciseId": "barbell_row",
      "swapHomeId": "resistance_band_rows"
    },
    {
      "exerciseId": "standing_calf_raise",
      "swapHomeId": "single_leg_calf_raise"
    },
    {
      "exerciseId": "medicine_ball_side_throw",
      "swapHomeId": "jump_rotation_arms"
    },
    {
      "exerciseId": "copenhagen_plank",
      "swapGymId": "adductor_squeeze"
    },
    {
      "exerciseId": "bike_intervals_30_30",
      "swapHomeId": "mountain_climber_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  // Week 4 - Same structure
  static const String _week4Session1 = '''
{
  "id": "attacker_w4_s1",
  "title": "Quadriceps + Pull > Push (Week 4)",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "skater_bounds"
    },
    {
      "exerciseId": "back_squat",
      "swapGymId": "goblet_squat",
      "swapHomeId": "bodyweight_squat"
    },
    {
      "exerciseId": "bulgarian_split_squat",
      "swapHomeId": "reverse_lunge"
    },
    {
      "exerciseId": "dumbbell_bench",
      "swapHomeId": "push_ups_decline"
    },
    {
      "exerciseId": "chest_supported_row",
      "swapHomeId": "resistance_band_rows"
    },
    {
      "exerciseId": "side_plank_reach"
    },
    {
      "exerciseId": "bike_intervals_30_30",
      "swapHomeId": "mountain_climber_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week4Session2 = '''
{
  "id": "attacker_w4_s2",
  "title": "Posterior + Épaules Saines (Week 4)",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "crossovers_off_ice"
    },
    {
      "exerciseId": "hip_thrust",
      "swapGymId": "romanian_deadlift",
      "swapHomeId": "single_leg_glute_bridge"
    },
    {
      "exerciseId": "lat_pulldown",
      "swapHomeId": "resistance_band_rows"
    },
    {
      "exerciseId": "arnold_press",
      "swapHomeId": "pike_push_ups"
    },
    {
      "exerciseId": "nordic_hamstring",
      "swapHomeId": "hamstring_curl_towel"
    },
    {
      "exerciseId": "face_pulls",
      "swapHomeId": "ytw_raises"
    },
    {
      "exerciseId": "pallof_press",
      "swapHomeId": "pallof_resistance_band"
    },
    {
      "exerciseId": "bike_intervals_20_40",
      "swapHomeId": "high_knees_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week4Session3 = '''
{
  "id": "attacker_w4_s3",
  "title": "Unilatéral + Rotation + Mollets (Week 4)",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "t_test"
    },
    {
      "exerciseId": "step_up",
      "swapHomeId": "stair_step_up"
    },
    {
      "exerciseId": "bulgarian_split_squat",
      "swapHomeId": "reverse_lunge"
    },
    {
      "exerciseId": "barbell_row",
      "swapHomeId": "resistance_band_rows"
    },
    {
      "exerciseId": "standing_calf_raise",
      "swapHomeId": "single_leg_calf_raise"
    },
    {
      "exerciseId": "medicine_ball_side_throw",
      "swapHomeId": "jump_rotation_arms"
    },
    {
      "exerciseId": "copenhagen_plank",
      "swapGymId": "adductor_squeeze"
    },
    {
      "exerciseId": "bike_intervals_30_30",
      "swapHomeId": "mountain_climber_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  // =============================================================================
  // WEEK 5 SESSIONS (Power & Max Strength - Taper)
  // =============================================================================

  static const String _week5Session1 = '''
{
  "id": "attacker_w5_s1",
  "title": "Neural - Bas du Corps",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "sprint_ladder"
    },
    {
      "exerciseId": "back_squat",
      "swapGymId": "goblet_squat",
      "swapHomeId": "jump_squat"
    },
    {
      "exerciseId": "bench_press",
      "swapGymId": "dumbbell_bench",
      "swapHomeId": "push_ups_weighted"
    },
    {
      "exerciseId": "power_clean",
      "swapGymId": "kettlebell_swing",
      "swapHomeId": "broad_jump"
    },
    {
      "exerciseId": "face_pulls",
      "swapHomeId": "ytw_raises"
    },
    {
      "exerciseId": "bike_intervals_15_45",
      "swapHomeId": "burpee_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week5Session2 = '''
{
  "id": "attacker_w5_s2",
  "title": "Neural - Post Chaîne + Tir",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "sprint_10m"
    },
    {
      "exerciseId": "deadlift",
      "swapGymId": "hip_thrust",
      "swapHomeId": "hip_hinge_backpack"
    },
    {
      "exerciseId": "overhead_press",
      "swapGymId": "dumbbell_press",
      "swapHomeId": "pike_push_ups"
    },
    {
      "exerciseId": "weighted_pull_ups",
      "swapGymId": "lat_pulldown",
      "swapHomeId": "towel_door_rows"
    },
    {
      "exerciseId": "nordic_hamstring",
      "swapHomeId": "hamstring_curl_towel"
    },
    {
      "exerciseId": "medicine_ball_slam",
      "swapHomeId": "squat_jump_clap"
    },
    {
      "exerciseId": "bike_intervals_10_50",
      "swapHomeId": "jump_squat_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  static const String _week5Session3 = '''
{
  "id": "attacker_w5_s3",
  "title": "Micro-dose Power - Taper",
  "blocks": [
    {
      "exerciseId": "dynamic_warmup_ramp"
    },
    {
      "exerciseId": "five_ten_five_shuttle"
    },
    {
      "exerciseId": "front_squat",
      "swapGymId": "split_squat_heavy",
      "swapHomeId": "pistol_squat_assist"
    },
    {
      "exerciseId": "dumbbell_bench",
      "swapHomeId": "push_ups_decline"
    },
    {
      "exerciseId": "barbell_row",
      "swapHomeId": "resistance_band_rows"
    },
    {
      "exerciseId": "copenhagen_plank",
      "swapGymId": "adductor_squeeze"
    },
    {
      "exerciseId": "hanging_leg_raises",
      "swapHomeId": "lying_leg_raises"
    },
    {
      "exerciseId": "bike_intervals_20_40",
      "swapHomeId": "high_knees_intervals"
    }
  ],
  "bonusChallenge": "XP Boost: Choose Force (+75 XP), Speed (+75 XP), Agility (+75 XP), or Conditioning (+50 XP)"
}
''';

  // =============================================================================
  // PROGRAM DEFINITION
  // =============================================================================

  static const String _attackerProgram = '''
{
  "id": "hockey_attacker_2025",
  "role": "attacker",
  "title": "🏒 Attacker - 5 Weeks (World-Class)",
  "weeks": [
    {
      "index": 0,
      "sessions": [
        "attacker_w1_s1",
        "attacker_w1_s2",
        "attacker_w1_s3"
      ]
    },
    {
      "index": 1,
      "sessions": [
        "attacker_w2_s1",
        "attacker_w2_s2",
        "attacker_w2_s3"
      ]
    },
    {
      "index": 2,
      "sessions": [
        "attacker_w3_s1",
        "attacker_w3_s2",
        "attacker_w3_s3"
      ]
    },
    {
      "index": 3,
      "sessions": [
        "attacker_w4_s1",
        "attacker_w4_s2",
        "attacker_w4_s3"
      ]
    },
    {
      "index": 4,
      "sessions": [
        "attacker_w5_s1",
        "attacker_w5_s2",
        "attacker_w5_s3"
      ]
    }
  ]
}
''';

  // =============================================================================
  // PUBLIC METHODS
  // =============================================================================

  /// Gets the complete attacker program
  static Future<Program?> getAttackerProgram() async {
    try {
      _logger.d('AttackerProgramData: Loading attacker program');

      final jsonData = jsonDecode(_attackerProgram) as Map<String, dynamic>;
      final program = Program.fromJson(jsonData);

      _logger.i('AttackerProgramData: Successfully loaded attacker program');
      return program;
    } catch (e, stackTrace) {
      _logger.e('AttackerProgramData: Failed to load attacker program',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Gets all sessions for the attacker program
  static Future<List<Session>> getAllSessions() async {
    try {
      _logger.d('AttackerProgramData: Loading all sessions');

      final sessions = <Session>[];

      // Session data map
      final sessionData = {
        'attacker_w1_s1': _week1Session1,
        'attacker_w1_s2': _week1Session2,
        'attacker_w1_s3': _week1Session3,
        'attacker_w2_s1': _week2Session1,
        'attacker_w2_s2': _week2Session2,
        'attacker_w2_s3': _week2Session3,
        'attacker_w3_s1': _week3Session1,
        'attacker_w3_s2': _week3Session2,
        'attacker_w3_s3': _week3Session3,
        'attacker_w4_s1': _week4Session1,
        'attacker_w4_s2': _week4Session2,
        'attacker_w4_s3': _week4Session3,
        'attacker_w5_s1': _week5Session1,
        'attacker_w5_s2': _week5Session2,
        'attacker_w5_s3': _week5Session3,
      };

      for (final entry in sessionData.entries) {
        final session = await _loadSession(entry.key, entry.value);
        if (session != null) {
          sessions.add(session);
        }
      }

      _logger.i('AttackerProgramData: Loaded ${sessions.length} sessions');
      return sessions;
    } catch (e, stackTrace) {
      _logger.e('AttackerProgramData: Failed to load sessions',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific session by ID
  static Future<Session?> getSessionById(String id) async {
    try {
      _logger.d('AttackerProgramData: Loading session with ID: $id');

      // Session data map
      final sessionData = {
        'attacker_w1_s1': _week1Session1,
        'attacker_w1_s2': _week1Session2,
        'attacker_w1_s3': _week1Session3,
        'attacker_w2_s1': _week2Session1,
        'attacker_w2_s2': _week2Session2,
        'attacker_w2_s3': _week2Session3,
        'attacker_w3_s1': _week3Session1,
        'attacker_w3_s2': _week3Session2,
        'attacker_w3_s3': _week3Session3,
        'attacker_w4_s1': _week4Session1,
        'attacker_w4_s2': _week4Session2,
        'attacker_w4_s3': _week4Session3,
        'attacker_w5_s1': _week5Session1,
        'attacker_w5_s2': _week5Session2,
        'attacker_w5_s3': _week5Session3,
      };

      final sessionJson = sessionData[id];
      if (sessionJson == null) {
        _logger.w('AttackerProgramData: Session not found: $id');
        return null;
      }

      return await _loadSession(id, sessionJson);
    } catch (e, stackTrace) {
      _logger.e('AttackerProgramData: Failed to load session $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // =============================================================================
  // PRIVATE METHODS
  // =============================================================================

  /// Loads a session from JSON string
  static Future<Session?> _loadSession(String id, String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final session = Session.fromJson(jsonData);

      _logger.d(
          'AttackerProgramData: Successfully loaded session: ${session.title}');
      return session;
    } catch (e, stackTrace) {
      _logger.e('AttackerProgramData: Failed to parse session JSON for $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
