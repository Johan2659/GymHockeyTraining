import '../../../core/models/models.dart';

/// Resolved view of a training session with fully materialized exercises.
class ResolvedSession {
  const ResolvedSession({
    required this.session,
    required this.exercises,
    required this.placeholderExerciseIds,
    required this.programId,
    required this.week,
    required this.sessionIndex,
  });

  final Session session;
  final List<Exercise> exercises;
  final Set<String> placeholderExerciseIds;
  final String programId;
  final int week;
  final int sessionIndex;

  /// Returns true if any exercises were substituted with placeholders.
  bool get hasPlaceholders => placeholderExerciseIds.isNotEmpty;

  /// Checks whether the provided [exercise] was synthesized as a placeholder.
  bool isPlaceholder(Exercise exercise) =>
      placeholderExerciseIds.contains(exercise.id);
}
<<<<<<< HEAD
=======

>>>>>>> b3d69919293f86865060415829b2d128c5028820
