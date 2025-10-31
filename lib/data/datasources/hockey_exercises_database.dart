import 'dart:convert';
import 'package:logger/logger.dart';
import '../../core/models/models.dart';

/// Comprehensive hockey exercises database
/// Contains all exercises with proper categorization and variants
class HockeyExercisesDatabase {
  static final _logger = Logger();

  // =============================================================================
  // STRENGTH EXERCISES
  // =============================================================================

  static const Map<String, String> _strengthExercises = {
    // Lower Body Strength
    'back_squat': '''
{
  "id": "back_squat",
  "name": "Back Squat",
  "category": "strength",
  "sets": 4,
  "reps": 5,
  "rest": 180,
  "youtubeQuery": "back squat hockey training",
  "gymAltId": "goblet_squat",
  "homeAltId": "jump_squat"
}
''',
    'goblet_squat': '''
{
  "id": "goblet_squat",
  "name": "Goblet Squat",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "goblet squat technique",
  "homeAltId": "bodyweight_squat"
}
''',
    'jump_squat': '''
{
  "id": "jump_squat",
  "name": "Jump Squat",
  "category": "power",
  "sets": 5,
  "reps": 5,
  "rest": 90,
  "youtubeQuery": "jump squat explosive power"
}
''',
    'front_squat': '''
{
  "id": "front_squat",
  "name": "Front Squat",
  "category": "strength",
  "sets": 4,
  "reps": 5,
  "rest": 180,
  "youtubeQuery": "front squat technique",
  "gymAltId": "split_squat_heavy",
  "homeAltId": "pistol_squat_assist"
}
''',
    'walking_lunge': '''
{
  "id": "walking_lunge",
  "name": "Walking Lunge",
  "category": "strength",
  "sets": 3,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "walking lunge hockey",
  "gymAltId": "split_squat",
  "homeAltId": "bodyweight_lunge"
}
''',
    'bulgarian_split_squat': '''
{
  "id": "bulgarian_split_squat",
  "name": "Bulgarian Split Squat",
  "category": "strength",
  "sets": 3,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "bulgarian split squat",
  "homeAltId": "reverse_lunge"
}
''',
    'step_up': '''
{
  "id": "step_up",
  "name": "Step-up (High)",
  "category": "strength",
  "sets": 3,
  "reps": 12,
  "rest": 90,
  "youtubeQuery": "step up exercise hockey",
  "homeAltId": "stair_step_up"
}
''',

    // Posterior Chain
    'deadlift': '''
{
  "id": "deadlift",
  "name": "Deadlift",
  "category": "strength",
  "sets": 4,
  "reps": 5,
  "rest": 180,
  "youtubeQuery": "deadlift hockey training",
  "gymAltId": "hip_thrust",
  "homeAltId": "hip_hinge_backpack"
}
''',
    'hip_thrust': '''
{
  "id": "hip_thrust",
  "name": "Hip Thrust",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "hip thrust exercise",
  "homeAltId": "single_leg_glute_bridge"
}
''',
    'romanian_deadlift': '''
{
  "id": "romanian_deadlift",
  "name": "Romanian Deadlift (RDL)",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "RDL romanian deadlift",
  "homeAltId": "single_leg_rdl"
}
''',
    'nordic_hamstring': '''
{
  "id": "nordic_hamstring",
  "name": "Nordic Hamstring Curl",
  "category": "strength",
  "sets": 3,
  "reps": 5,
  "rest": 120,
  "youtubeQuery": "nordic hamstring curl",
  "gymAltId": "leg_curl",
  "homeAltId": "hamstring_curl_towel"
}
''',

    // Upper Body Push
    'bench_press': '''
{
  "id": "bench_press",
  "name": "Bench Press (Développé Couché)",
  "category": "strength",
  "sets": 4,
  "reps": 6,
  "rest": 150,
  "youtubeQuery": "bench press hockey training",
  "gymAltId": "dumbbell_bench",
  "homeAltId": "push_ups_weighted"
}
''',
    'dumbbell_bench': '''
{
  "id": "dumbbell_bench",
  "name": "Dumbbell Bench Press",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "dumbbell bench press",
  "homeAltId": "push_ups_decline"
}
''',
    'overhead_press': '''
{
  "id": "overhead_press",
  "name": "Overhead Press (Military)",
  "category": "strength",
  "sets": 4,
  "reps": 6,
  "rest": 150,
  "youtubeQuery": "overhead press military",
  "gymAltId": "dumbbell_press",
  "homeAltId": "pike_push_ups"
}
''',
    'landmine_press': '''
{
  "id": "landmine_press",
  "name": "Landmine Press (Unilateral)",
  "category": "strength",
  "sets": 4,
  "reps": 6,
  "rest": 120,
  "youtubeQuery": "landmine press unilateral",
  "gymAltId": "dumbbell_incline_unilateral",
  "homeAltId": "single_arm_push_up"
}
''',
    'arnold_press': '''
{
  "id": "arnold_press",
  "name": "Arnold Press",
  "category": "strength",
  "sets": 3,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "arnold press shoulders",
  "homeAltId": "pike_push_ups"
}
''',

    // Upper Body Pull
    'weighted_pull_ups': '''
{
  "id": "weighted_pull_ups",
  "name": "Weighted Pull-ups",
  "category": "strength",
  "sets": 4,
  "reps": 6,
  "rest": 150,
  "youtubeQuery": "weighted pull ups",
  "gymAltId": "lat_pulldown",
  "homeAltId": "towel_door_rows"
}
''',
    'lat_pulldown': '''
{
  "id": "lat_pulldown",
  "name": "Lat Pulldown",
  "category": "strength",
  "sets": 4,
  "reps": 10,
  "rest": 120,
  "youtubeQuery": "lat pulldown technique",
  "homeAltId": "resistance_band_rows"
}
''',
    'barbell_row': '''
{
  "id": "barbell_row",
  "name": "Barbell Row",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "barbell row hockey",
  "gymAltId": "chest_supported_row",
  "homeAltId": "backpack_row_table"
}
''',
    'chest_supported_row': '''
{
  "id": "chest_supported_row",
  "name": "Chest-Supported Row",
  "category": "strength",
  "sets": 4,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "chest supported row",
  "homeAltId": "resistance_band_rows"
}
''',
    'one_arm_row': '''
{
  "id": "one_arm_row",
  "name": "One-Arm Row",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "one arm dumbbell row",
  "homeAltId": "backpack_row"
}
''',

    // Calves
    'standing_calf_raise': '''
{
  "id": "standing_calf_raise",
  "name": "Standing Calf Raise",
  "category": "strength",
  "sets": 4,
  "reps": 15,
  "rest": 60,
  "youtubeQuery": "standing calf raise",
  "homeAltId": "single_leg_calf_raise"
}
''',

    // Missing Home Alternatives
    'bodyweight_squat': '''
{
  "id": "bodyweight_squat",
  "name": "Bodyweight Squat",
  "category": "strength",
  "sets": 3,
  "reps": 15,
  "rest": 60,
  "youtubeQuery": "bodyweight squat form"
}
''',
    'bodyweight_lunge': '''
{
  "id": "bodyweight_lunge",
  "name": "Bodyweight Lunge",
  "category": "strength",
  "sets": 3,
  "reps": 12,
  "rest": 60,
  "youtubeQuery": "bodyweight lunge technique"
}
''',
    'split_squat': '''
{
  "id": "split_squat",
  "name": "Split Squat",
  "category": "strength",
  "sets": 3,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "split squat exercise"
}
''',
    'split_squat_heavy': '''
{
  "id": "split_squat_heavy",
  "name": "Split Squat (Heavy)",
  "category": "strength",
  "sets": 4,
  "reps": 6,
  "rest": 120,
  "youtubeQuery": "weighted split squat"
}
''',
    'pistol_squat_assist': '''
{
  "id": "pistol_squat_assist",
  "name": "Pistol Squat (Assisted)",
  "category": "strength",
  "sets": 4,
  "reps": 5,
  "rest": 120,
  "youtubeQuery": "assisted pistol squat"
}
''',
    'hip_hinge_backpack': '''
{
  "id": "hip_hinge_backpack",
  "name": "Hip Hinge with Backpack",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "hip hinge deadlift home"
}
''',
    'single_leg_glute_bridge': '''
{
  "id": "single_leg_glute_bridge",
  "name": "Single Leg Glute Bridge",
  "category": "strength",
  "sets": 3,
  "reps": 12,
  "rest": 90,
  "youtubeQuery": "single leg glute bridge"
}
''',
    'single_leg_rdl': '''
{
  "id": "single_leg_rdl",
  "name": "Single Leg RDL",
  "category": "strength",
  "sets": 3,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "single leg romanian deadlift"
}
''',
    'hamstring_curl_towel': '''
{
  "id": "hamstring_curl_towel",
  "name": "Hamstring Curl (Towel)",
  "category": "strength",
  "sets": 3,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "towel hamstring curl home"
}
''',
    'leg_curl': '''
{
  "id": "leg_curl",
  "name": "Leg Curl Machine",
  "category": "strength",
  "sets": 3,
  "reps": 12,
  "rest": 90,
  "youtubeQuery": "leg curl machine technique"
}
''',
    'push_ups_weighted': '''
{
  "id": "push_ups_weighted",
  "name": "Weighted Push-ups",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "weighted push ups backpack"
}
''',
    'push_ups_decline': '''
{
  "id": "push_ups_decline",
  "name": "Decline Push-ups",
  "category": "strength",
  "sets": 3,
  "reps": 12,
  "rest": 90,
  "youtubeQuery": "decline push ups feet elevated"
}
''',
    'pike_push_ups': '''
{
  "id": "pike_push_ups",
  "name": "Pike Push-ups",
  "category": "strength",
  "sets": 3,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "pike push ups shoulders"
}
''',
    'single_arm_push_up': '''
{
  "id": "single_arm_push_up",
  "name": "Single Arm Push-up",
  "category": "strength",
  "sets": 4,
  "reps": 4,
  "rest": 120,
  "youtubeQuery": "single arm push up progression"
}
''',
    'dumbbell_incline_unilateral': '''
{
  "id": "dumbbell_incline_unilateral",
  "name": "Dumbbell Incline Press (Unilateral)",
  "category": "strength",
  "sets": 4,
  "reps": 6,
  "rest": 120,
  "youtubeQuery": "single arm incline dumbbell press"
}
''',
    'dumbbell_press': '''
{
  "id": "dumbbell_press",
  "name": "Dumbbell Overhead Press",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "dumbbell shoulder press"
}
''',
    'towel_door_rows': '''
{
  "id": "towel_door_rows",
  "name": "Towel Door Rows",
  "category": "strength",
  "sets": 4,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "towel door row home exercise"
}
''',
    'resistance_band_rows': '''
{
  "id": "resistance_band_rows",
  "name": "Resistance Band Rows",
  "category": "strength",
  "sets": 4,
  "reps": 12,
  "rest": 90,
  "youtubeQuery": "resistance band rows"
}
''',
    'backpack_row_table': '''
{
  "id": "backpack_row_table",
  "name": "Backpack Row Under Table",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "inverted row under table"
}
''',
    'backpack_row': '''
{
  "id": "backpack_row",
  "name": "Backpack Row",
  "category": "strength",
  "sets": 4,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "bent over row backpack"
}
''',
    'single_leg_calf_raise': '''
{
  "id": "single_leg_calf_raise",
  "name": "Single Leg Calf Raise",
  "category": "strength",
  "sets": 4,
  "reps": 12,
  "rest": 60,
  "youtubeQuery": "single leg calf raise"
}
''',
    'cable_rotation': '''
{
  "id": "cable_rotation",
  "name": "Cable Rotation",
  "category": "strength",
  "sets": 3,
  "reps": 8,
  "rest": 60,
  "youtubeQuery": "cable rotation core exercise"
}
''',
    'resistance_band_rotation': '''
{
  "id": "resistance_band_rotation",
  "name": "Resistance Band Rotation",
  "category": "strength",
  "sets": 3,
  "reps": 8,
  "rest": 60,
  "youtubeQuery": "resistance band core rotation"
}
''',
    'pallof_resistance_band': '''
{
  "id": "pallof_resistance_band",
  "name": "Pallof Press (Resistance Band)",
  "category": "strength",
  "sets": 3,
  "reps": 10,
  "rest": 60,
  "youtubeQuery": "pallof press resistance band"
}
''',
    'adductor_squeeze': '''
{
  "id": "adductor_squeeze",
  "name": "Adductor Squeeze",
  "category": "strength",
  "sets": 3,
  "reps": 15,
  "rest": 60,
  "youtubeQuery": "adductor squeeze ball exercise"
}
''',
    'lying_leg_raises': '''
{
  "id": "lying_leg_raises",
  "name": "Lying Leg Raises",
  "category": "strength",
  "sets": 3,
  "reps": 12,
  "rest": 90,
  "youtubeQuery": "lying leg raises abs"
}
''',
    'jump_rotation_arms': '''
{
  "id": "jump_rotation_arms",
  "name": "Jump + Rotation (Arms Extended)",
  "category": "power",
  "sets": 4,
  "reps": 5,
  "rest": 90,
  "youtubeQuery": "rotational jump training"
}
''',
    'squat_jump_clap': '''
{
  "id": "squat_jump_clap",
  "name": "Squat Jump + Clap",
  "category": "power",
  "sets": 3,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "squat jump clap overhead"
}
''',
    'reverse_lunge': '''
{
  "id": "reverse_lunge",
  "name": "Reverse Lunge",
  "category": "strength",
  "sets": 3,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "reverse lunge technique"
}
''',
    'stair_step_up': '''
{
  "id": "stair_step_up",
  "name": "Stair Step-up",
  "category": "strength",
  "sets": 3,
  "reps": 12,
  "rest": 90,
  "youtubeQuery": "stair step up exercise"
}
''',
    'burpee_intervals': '''
{
  "id": "burpee_intervals",
  "name": "Burpee Intervals",
  "category": "conditioning",
  "sets": 6,
  "reps": 1,
  "duration": 15,
  "rest": 45,
  "youtubeQuery": "burpee intervals workout"
}
''',
    'jump_squat_intervals': '''
{
  "id": "jump_squat_intervals",
  "name": "Jump Squat Intervals",
  "category": "conditioning",
  "sets": 8,
  "reps": 1,
  "duration": 10,
  "rest": 50,
  "youtubeQuery": "jump squat intervals training"
}
''',
  };

  // =============================================================================
  // POWER & PLYOMETRIC EXERCISES
  // =============================================================================

  static const Map<String, String> _powerExercises = {
    'power_clean': '''
{
  "id": "power_clean",
  "name": "Power Clean",
  "category": "power",
  "sets": 4,
  "reps": 3,
  "rest": 180,
  "youtubeQuery": "power clean technique",
  "gymAltId": "kettlebell_swing",
  "homeAltId": "broad_jump"
}
''',
    'kettlebell_swing': '''
{
  "id": "kettlebell_swing",
  "name": "Kettlebell Swing",
  "category": "power",
  "sets": 5,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "kettlebell swing hockey",
  "homeAltId": "jump_squat"
}
''',
    'medicine_ball_slam': '''
{
  "id": "medicine_ball_slam",
  "name": "Medicine Ball Slam",
  "category": "power",
  "sets": 3,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "medicine ball slam",
  "homeAltId": "squat_jump_clap"
}
''',
    'medicine_ball_side_throw': '''
{
  "id": "medicine_ball_side_throw",
  "name": "Medicine Ball Side Throw",
  "category": "power",
  "sets": 4,
  "reps": 5,
  "rest": 90,
  "youtubeQuery": "medicine ball rotational throw",
  "homeAltId": "jump_rotation_arms"
}
''',
    'broad_jump': '''
{
  "id": "broad_jump",
  "name": "Broad Jump",
  "category": "power",
  "sets": 6,
  "reps": 3,
  "rest": 120,
  "youtubeQuery": "broad jump training"
}
''',
    'box_jump': '''
{
  "id": "box_jump",
  "name": "Box Jump",
  "category": "power",
  "sets": 5,
  "reps": 5,
  "rest": 120,
  "youtubeQuery": "box jump technique"
}
''',
  };

  // =============================================================================
  // AGILITY & SPEED EXERCISES
  // =============================================================================

  static const Map<String, String> _agilitySpeedExercises = {
    'skater_bounds': '''
{
  "id": "skater_bounds",
  "name": "Skater Bounds",
  "category": "agility",
  "sets": 4,
  "reps": 6,
  "rest": 90,
  "youtubeQuery": "skater bounds hockey agility"
}
''',
    'five_ten_five_shuttle': '''
{
  "id": "five_ten_five_shuttle",
  "name": "5-10-5 Shuttle Run",
  "category": "agility",
  "sets": 4,
  "reps": 1,
  "rest": 120,
  "youtubeQuery": "5 10 5 shuttle run"
}
''',
    'sprint_10m': '''
{
  "id": "sprint_10m",
  "name": "10m Sprint",
  "category": "speed",
  "sets": 6,
  "reps": 1,
  "rest": 90,
  "youtubeQuery": "10 meter sprint training"
}
''',
    'sprint_flying_start': '''
{
  "id": "sprint_flying_start",
  "name": "Flying Start Sprint",
  "category": "speed",
  "sets": 4,
  "reps": 1,
  "rest": 120,
  "youtubeQuery": "flying start sprint"
}
''',
    'lateral_shuffle': '''
{
  "id": "lateral_shuffle",
  "name": "Lateral Shuffle",
  "category": "agility",
  "sets": 3,
  "reps": 1,
  "duration": 20,
  "rest": 60,
  "youtubeQuery": "lateral shuffle drill"
}
''',
    'crossovers_off_ice': '''
{
  "id": "crossovers_off_ice",
  "name": "Crossovers Off-Ice",
  "category": "agility",
  "sets": 3,
  "reps": 1,
  "duration": 20,
  "rest": 60,
  "youtubeQuery": "hockey crossovers off ice"
}
''',
    't_test': '''
{
  "id": "t_test",
  "name": "T-Test Agility",
  "category": "agility",
  "sets": 3,
  "reps": 1,
  "rest": 120,
  "youtubeQuery": "t test agility drill"
}
''',
    'sprint_ladder': '''
{
  "id": "sprint_ladder",
  "name": "Sprint Ladder (10-20-30m)",
  "category": "speed",
  "sets": 2,
  "reps": 1,
  "rest": 180,
  "youtubeQuery": "sprint ladder progression"
}
''',
  };

  // =============================================================================
  // CORE & PREVENTION EXERCISES
  // =============================================================================

  static const Map<String, String> _corePreventionExercises = {
    'pallof_press': '''
{
  "id": "pallof_press",
  "name": "Pallof Press",
  "category": "strength",
  "sets": 3,
  "reps": 10,
  "rest": 60,
  "youtubeQuery": "pallof press anti rotation",
  "gymAltId": "cable_rotation",
  "homeAltId": "pallof_resistance_band"
}
''',
    'pallof_press_rotation': '''
{
  "id": "pallof_press_rotation",
  "name": "Pallof Press with Rotation",
  "category": "strength",
  "sets": 3,
  "reps": 8,
  "rest": 60,
  "youtubeQuery": "pallof press rotation",
  "homeAltId": "resistance_band_rotation"
}
''',
    'copenhagen_plank': '''
{
  "id": "copenhagen_plank",
  "name": "Copenhagen Plank",
  "category": "strength",
  "sets": 3,
  "reps": 1,
  "duration": 25,
  "rest": 90,
  "youtubeQuery": "copenhagen plank adductors",
  "gymAltId": "adductor_squeeze"
}
''',
    'side_plank_reach': '''
{
  "id": "side_plank_reach",
  "name": "Side Plank + Reach",
  "category": "strength",
  "sets": 3,
  "reps": 1,
  "duration": 45,
  "rest": 60,
  "youtubeQuery": "side plank with reach"
}
''',
    'hanging_leg_raises': '''
{
  "id": "hanging_leg_raises",
  "name": "Hanging Leg Raises",
  "category": "strength",
  "sets": 3,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "hanging leg raises",
  "homeAltId": "lying_leg_raises"
}
''',
    'face_pulls': '''
{
  "id": "face_pulls",
  "name": "Face Pulls",
  "category": "recovery",
  "sets": 3,
  "reps": 15,
  "rest": 60,
  "youtubeQuery": "face pulls rear delt",
  "homeAltId": "ytw_raises"
}
''',
    'ytw_raises': '''
{
  "id": "ytw_raises",
  "name": "Y-T-W Raises",
  "category": "recovery",
  "sets": 3,
  "reps": 15,
  "rest": 60,
  "youtubeQuery": "ytw raises shoulders"
}
''',
  };

  // =============================================================================
  // CONDITIONING EXERCISES
  // =============================================================================

  static const Map<String, String> _conditioningExercises = {
    'bike_intervals_20_40': '''
{
  "id": "bike_intervals_20_40",
  "name": "Bike Intervals 20s/40s",
  "category": "conditioning",
  "sets": 6,
  "reps": 1,
  "duration": 20,
  "rest": 40,
  "youtubeQuery": "bike intervals hockey training",
  "homeAltId": "high_knees_intervals"
}
''',
    'bike_intervals_30_30': '''
{
  "id": "bike_intervals_30_30",
  "name": "Bike Intervals 30s/30s",
  "category": "conditioning",
  "sets": 8,
  "reps": 1,
  "duration": 30,
  "rest": 30,
  "youtubeQuery": "30 30 intervals bike",
  "homeAltId": "mountain_climber_intervals"
}
''',
    'bike_intervals_15_45': '''
{
  "id": "bike_intervals_15_45",
  "name": "Bike Intervals 15s/45s",
  "category": "conditioning",
  "sets": 6,
  "reps": 1,
  "duration": 15,
  "rest": 45,
  "youtubeQuery": "15 45 sprint intervals",
  "homeAltId": "burpee_intervals"
}
''',
    'bike_intervals_10_50': '''
{
  "id": "bike_intervals_10_50",
  "name": "Bike Intervals 10s/50s",
  "category": "conditioning",
  "sets": 8,
  "reps": 1,
  "duration": 10,
  "rest": 50,
  "youtubeQuery": "10 50 power intervals",
  "homeAltId": "jump_squat_intervals"
}
''',
    'high_knees_intervals': '''
{
  "id": "high_knees_intervals",
  "name": "High Knees Intervals",
  "category": "conditioning",
  "sets": 6,
  "reps": 1,
  "duration": 20,
  "rest": 40,
  "youtubeQuery": "high knees cardio intervals"
}
''',
    'mountain_climber_intervals': '''
{
  "id": "mountain_climber_intervals",
  "name": "Mountain Climber Intervals",
  "category": "conditioning",
  "sets": 8,
  "reps": 1,
  "duration": 30,
  "rest": 30,
  "youtubeQuery": "mountain climber intervals"
}
''',
  };

  // =============================================================================
  // WARMUP EXERCISES
  // =============================================================================

  static const Map<String, String> _warmupExercises = {
    'dynamic_warmup_ramp': '''
{
  "id": "dynamic_warmup_ramp",
  "name": "Dynamic RAMP Warmup",
  "category": "warmup",
  "sets": 1,
  "reps": 1,
  "duration": 480,
  "rest": 0,
  "youtubeQuery": "hockey ramp warmup dynamic"
}
''',
    'leg_swings': '''
{
  "id": "leg_swings",
  "name": "Leg Swings",
  "category": "warmup",
  "sets": 2,
  "reps": 10,
  "rest": 30,
  "youtubeQuery": "leg swings dynamic warmup"
}
''',
    'hip_circles': '''
{
  "id": "hip_circles",
  "name": "Hip Circles",
  "category": "warmup",
  "sets": 2,
  "reps": 10,
  "rest": 30,
  "youtubeQuery": "hip circles mobility"
}
''',
    'arm_circles': '''
{
  "id": "arm_circles",
  "name": "Arm Circles",
  "category": "warmup",
  "sets": 2,
  "reps": 10,
  "rest": 30,
  "youtubeQuery": "arm circles warmup"
}
''',
  };

  // =============================================================================
  // BONUS EXERCISES
  // =============================================================================

  static const Map<String, String> _bonusExercises = {
    'farmer_walk': '''
{
  "id": "farmer_walk",
  "name": "Farmer Walk",
  "category": "strength",
  "sets": 3,
  "reps": 1,
  "duration": 30,
  "rest": 90,
  "youtubeQuery": "farmer walk strength",
  "homeAltId": "heavy_bag_carry"
}
''',
    'heavy_bag_carry': '''
{
  "id": "heavy_bag_carry",
  "name": "Heavy Bag Carry",
  "category": "strength",
  "sets": 3,
  "reps": 1,
  "duration": 30,
  "rest": 90,
  "youtubeQuery": "heavy bag carry workout"
}
''',
    'conditioning_5x30_30': '''
{
  "id": "conditioning_5x30_30",
  "name": "5x30/30 RPE 8 Intervals",
  "category": "conditioning",
  "sets": 5,
  "reps": 1,
  "duration": 30,
  "rest": 30,
  "youtubeQuery": "30 30 intervals conditioning"
}
''',
  };

  // =============================================================================
  // PUBLIC METHODS
  // =============================================================================

  /// Gets all exercises from the database
  static Future<List<Exercise>> getAllExercises() async {
    try {
      _logger.d('HockeyExercisesDatabase: Loading all exercises');

      final exercises = <Exercise>[];

      // Combine all exercise maps
      final allExerciseData = <String, String>{
        ..._strengthExercises,
        ..._powerExercises,
        ..._agilitySpeedExercises,
        ..._corePreventionExercises,
        ..._conditioningExercises,
        ..._warmupExercises,
        ..._bonusExercises,
      };

      for (final entry in allExerciseData.entries) {
        final exercise = await _loadExercise(entry.key, entry.value);
        if (exercise != null) {
          exercises.add(exercise);
        }
      }

      _logger
          .i('HockeyExercisesDatabase: Loaded ${exercises.length} exercises');
      return exercises;
    } catch (e, stackTrace) {
      _logger.e('HockeyExercisesDatabase: Failed to load exercises',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific exercise by ID
  static Future<Exercise?> getExerciseById(String id) async {
    try {
      _logger.d('HockeyExercisesDatabase: Loading exercise with ID: $id');

      // Search through all exercise maps
      final allExerciseData = <String, String>{
        ..._strengthExercises,
        ..._powerExercises,
        ..._agilitySpeedExercises,
        ..._corePreventionExercises,
        ..._conditioningExercises,
        ..._warmupExercises,
        ..._bonusExercises,
      };

      final exerciseJson = allExerciseData[id];
      if (exerciseJson == null) {
        _logger.w('HockeyExercisesDatabase: Exercise not found: $id');
        return null;
      }

      return await _loadExercise(id, exerciseJson);
    } catch (e, stackTrace) {
      _logger.e('HockeyExercisesDatabase: Failed to load exercise $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Gets exercises by category
  static Future<List<Exercise>> getExercisesByCategory(
      ExerciseCategory category) async {
    try {
      _logger.d(
          'HockeyExercisesDatabase: Loading exercises for category: $category');

      final allExercises = await getAllExercises();
      final categoryExercises = allExercises
          .where((exercise) => exercise.category == category)
          .toList();

      _logger.d(
          'HockeyExercisesDatabase: Found ${categoryExercises.length} exercises for category $category');
      return categoryExercises;
    } catch (e, stackTrace) {
      _logger.e(
          'HockeyExercisesDatabase: Failed to load exercises for category $category',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Searches exercises by query
  static Future<List<Exercise>> searchExercises(String query) async {
    try {
      _logger
          .d('HockeyExercisesDatabase: Searching exercises with query: $query');

      final allExercises = await getAllExercises();
      final lowercaseQuery = query.toLowerCase();

      final searchResults = allExercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(lowercaseQuery) ||
              exercise.category.name.toLowerCase().contains(lowercaseQuery))
          .toList();

      _logger.d(
          'HockeyExercisesDatabase: Found ${searchResults.length} exercises matching query');
      return searchResults;
    } catch (e, stackTrace) {
      _logger.e('HockeyExercisesDatabase: Failed to search exercises',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // =============================================================================
  // PRIVATE METHODS
  // =============================================================================

  /// Loads an exercise from JSON string
  static Future<Exercise?> _loadExercise(String id, String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final exercise = Exercise.fromJson(jsonData);

      _logger.d(
          'HockeyExercisesDatabase: Successfully loaded exercise: ${exercise.name}');
      return exercise;
    } catch (e, stackTrace) {
      _logger.e(
          'HockeyExercisesDatabase: Failed to parse exercise JSON for $id',
          error: e,
          stackTrace: stackTrace);
      return null;
    }
  }
}
