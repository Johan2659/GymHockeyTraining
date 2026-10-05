import 'package:flutter_test/flutter_test.dart';
import 'package:gymhockeytraining/data/datasources/extras/express_workouts.dart';
import 'package:gymhockeytraining/data/datasources/hockey_exercises_database.dart';

void main() {
  test('Every express workout resolves real exercise IDs', () async {
    final workouts = await ExpressWorkoutsData.getAllExpressWorkouts();
    expect(workouts.any((item) => item.duration == 30), isTrue);
    expect(workouts.map((item) => item.id).toSet().length, workouts.length);
    for (final workout in workouts) {
      expect(workout.blocks, isNotEmpty);
      for (final block in workout.blocks) {
        expect(
          await HockeyExercisesDatabase.getExerciseById(block.exerciseId),
          isNotNull,
          reason: '${workout.id}: ${block.exerciseId}',
        );
      }
    }
  });
}
