import 'dart:convert';
import 'package:logger/logger.dart';
import '../../core/models/models.dart';

/// Local data source for exercises using embedded JSON data
/// Provides exercise definitions with metadata
class LocalExerciseSource {
  static final _logger = Logger();
  
  // Static exercise data for hockey training
  static const Map<String, String> _exerciseData = {
    'ex_warmup_skate': '''
{
  "id": "ex_warmup_skate",
  "name": "Dynamic Skating Warmup",
  "category": "warmup",
  "sets": 1,
  "reps": 10,
  "duration": 300,
  "rest": 60,
  "youtubeQuery": "hockey skating warmup drills"
}
''',
    'ex_warmup_jog': '''
{
  "id": "ex_warmup_jog",
  "name": "Light Jogging",
  "category": "warmup",
  "sets": 1,
  "reps": 1,
  "duration": 300,
  "rest": 60,
  "youtubeQuery": "light jogging warmup"
}
''',
    'ex_warmup_shadowbox': '''
{
  "id": "ex_warmup_shadowbox",
  "name": "Shadow Boxing",
  "category": "warmup",
  "sets": 3,
  "reps": 20,
  "rest": 30,
  "youtubeQuery": "shadow boxing warmup"
}
''',
    'ex_cone_weaving': '''
{
  "id": "ex_cone_weaving",
  "name": "Cone Weaving Drills",
  "category": "agility",
  "sets": 3,
  "reps": 5,
  "rest": 90,
  "youtubeQuery": "hockey cone weaving drills"
}
''',
    'ex_sprint_intervals': '''
{
  "id": "ex_sprint_intervals",
  "name": "Sprint Intervals",
  "category": "speed",
  "sets": 4,
  "reps": 30,
  "duration": 30,
  "rest": 120,
  "youtubeQuery": "sprint interval training"
}
''',
    'ex_cooldown_stretch': '''
{
  "id": "ex_cooldown_stretch",
  "name": "Cool Down Stretching",
  "category": "recovery",
  "sets": 1,
  "reps": 1,
  "duration": 600,
  "rest": 0,
  "youtubeQuery": "hockey cooldown stretching"
}
''',
    'ex_stick_handling_figure8': '''
{
  "id": "ex_stick_handling_figure8",
  "name": "Stick Handling Figure 8s",
  "category": "stick_skills",
  "sets": 3,
  "reps": 10,
  "rest": 60,
  "youtubeQuery": "hockey stick handling figure 8"
}
''',
    'ex_shooting_accuracy': '''
{
  "id": "ex_shooting_accuracy",
  "name": "Shooting Accuracy",
  "category": "stick_skills",
  "sets": 3,
  "reps": 10,
  "rest": 90,
  "youtubeQuery": "hockey shooting accuracy drills"
}
''',
    'ex_plyometric_jumps': '''
{
  "id": "ex_plyometric_jumps",
  "name": "Plyometric Jump Training",
  "category": "power",
  "sets": 4,
  "reps": 8,
  "rest": 120,
  "youtubeQuery": "plyometric jump training hockey"
}
''',
    'ex_explosive_starts': '''
{
  "id": "ex_explosive_starts",
  "name": "Explosive Start Practice",
  "category": "speed",
  "sets": 5,
  "reps": 3,
  "rest": 90,
  "youtubeQuery": "hockey explosive start drills"
}
''',
    'ex_acceleration_drills': '''
{
  "id": "ex_acceleration_drills",
  "name": "Acceleration Drills",
  "category": "speed",
  "sets": 4,
  "reps": 5,
  "rest": 120,
  "youtubeQuery": "hockey acceleration training"
}
''',
    'ex_direction_changes': '''
{
  "id": "ex_direction_changes",
  "name": "Quick Direction Changes",
  "category": "agility",
  "sets": 3,
  "reps": 8,
  "rest": 90,
  "youtubeQuery": "hockey direction change drills"
}
''',
    'ex_one_handed_control': '''
{
  "id": "ex_one_handed_control",
  "name": "One-Handed Stick Control",
  "category": "stick_skills",
  "sets": 3,
  "reps": 15,
  "rest": 60,
  "youtubeQuery": "hockey one handed stick control"
}
''',
    'ex_backhand_shots': '''
{
  "id": "ex_backhand_shots",
  "name": "Backhand Shot Practice",
  "category": "stick_skills",
  "sets": 3,
  "reps": 12,
  "rest": 90,
  "youtubeQuery": "hockey backhand shot technique"
}
''',
    'ex_breakaway_practice': '''
{
  "id": "ex_breakaway_practice",
  "name": "Breakaway Simulation",
  "category": "game_situation",
  "sets": 5,
  "reps": 3,
  "rest": 120,
  "youtubeQuery": "hockey breakaway drills"
}
''',
    'ex_battle_drills': '''
{
  "id": "ex_battle_drills",
  "name": "Puck Battle Drills",
  "category": "game_situation",
  "sets": 4,
  "reps": 5,
  "rest": 90,
  "youtubeQuery": "hockey puck battle drills"
}
'''
  };

  /// Gets all available exercises
  Future<List<Exercise>> getAllExercises() async {
    try {
      _logger.d('LocalExerciseSource: Loading all exercises');
      
      final exercises = <Exercise>[];
      
      for (final entry in _exerciseData.entries) {
        final exercise = await _loadExercise(entry.key, entry.value);
        if (exercise != null) {
          exercises.add(exercise);
        }
      }
      
      _logger.i('LocalExerciseSource: Loaded ${exercises.length} exercises');
      return exercises;
      
    } catch (e, stackTrace) {
      _logger.e('LocalExerciseSource: Failed to load exercises', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific exercise by ID
  Future<Exercise?> getExerciseById(String id) async {
    try {
      _logger.d('LocalExerciseSource: Loading exercise with ID: $id');
      
      final exerciseJson = _exerciseData[id];
      if (exerciseJson == null) {
        _logger.w('LocalExerciseSource: Exercise not found: $id');
        return null;
      }
      
      return await _loadExercise(id, exerciseJson);
      
    } catch (e, stackTrace) {
      _logger.e('LocalExerciseSource: Failed to load exercise $id', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Gets exercises by category
  Future<List<Exercise>> getExercisesByCategory(String category) async {
    try {
      _logger.d('LocalExerciseSource: Loading exercises for category: $category');
      
      final allExercises = await getAllExercises();
      final categoryExercises = allExercises
          .where((exercise) => exercise.category.name.toLowerCase() == category.toLowerCase())
          .toList();
      
      _logger.d('LocalExerciseSource: Found ${categoryExercises.length} exercises for category $category');
      return categoryExercises;
      
    } catch (e, stackTrace) {
      _logger.e('LocalExerciseSource: Failed to load exercises for category $category', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Searches exercises by query
  Future<List<Exercise>> searchExercises(String query) async {
    try {
      _logger.d('LocalExerciseSource: Searching exercises with query: $query');
      
      final allExercises = await getAllExercises();
      final lowercaseQuery = query.toLowerCase();
      
      final searchResults = allExercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(lowercaseQuery) ||
              exercise.category.name.toLowerCase().contains(lowercaseQuery))
          .toList();
      
      _logger.d('LocalExerciseSource: Found ${searchResults.length} exercises matching query');
      return searchResults;
      
    } catch (e, stackTrace) {
      _logger.e('LocalExerciseSource: Failed to search exercises', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Loads an exercise from JSON string
  Future<Exercise?> _loadExercise(String id, String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final exercise = Exercise.fromJson(jsonData);
      
      _logger.d('LocalExerciseSource: Successfully loaded exercise: ${exercise.name}');
      return exercise;
      
    } catch (e, stackTrace) {
      _logger.e('LocalExerciseSource: Failed to parse exercise JSON for $id', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
