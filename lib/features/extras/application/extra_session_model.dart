import '../../../core/models/models.dart';

/// Resolved view of an extra session with fully materialized exercises.
class ResolvedExtraSession {
  const ResolvedExtraSession({
    required this.extra,
    required this.exercises,
    required this.placeholderExerciseIds,
  });

  final ExtraItem extra;
  final List<Exercise> exercises;
  final Set<String> placeholderExerciseIds;

  /// Returns true if any exercises were substituted with placeholders.
  bool get hasPlaceholders => placeholderExerciseIds.isNotEmpty;

  /// Checks whether the provided [exercise] was synthesized as a placeholder.
  bool isPlaceholder(Exercise exercise) =>
      placeholderExerciseIds.contains(exercise.id);
}
