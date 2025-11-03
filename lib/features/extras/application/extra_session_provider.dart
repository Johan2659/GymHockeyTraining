import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../app/di.dart';
import '../../../core/models/models.dart';
import 'extra_session_model.dart';

final _logger = Logger();

/// Provides a [ResolvedExtraSession] with exercises loaded from the database.
final resolvedExtraSessionProvider = FutureProvider.autoDispose
    .family<ResolvedExtraSession?, String>((ref, extraId) async {
  final extrasRepository = ref.watch(extrasRepositoryProvider);
  final exerciseRepository = ref.watch(exerciseRepositoryProvider);

  final extra = await extrasRepository.getById(extraId);
  if (extra == null) {
    _logger
        .w('resolvedExtraSessionProvider: Extra not found (extraId: $extraId)');
    return null;
  }

  final placeholderIds = <String>{};
  final exercises = <Exercise>[];

  for (final block in extra.blocks) {
    final exercise = await exerciseRepository.getById(block.exerciseId);
    if (exercise != null) {
      exercises.add(exercise);
    } else {
      placeholderIds.add(block.exerciseId);
      final placeholder = _createPlaceholderExercise(block.exerciseId);
      exercises.add(placeholder);

      _logger.w(
        'resolvedExtraSessionProvider: Using placeholder exercise (extraId: $extraId, exerciseId: ${block.exerciseId})',
      );
    }
  }

  return ResolvedExtraSession(
    extra: extra,
    exercises: exercises,
    placeholderExerciseIds: placeholderIds,
  );
});

Exercise _createPlaceholderExercise(String exerciseId) {
  final displayName = _humanizeId(exerciseId);

  return Exercise(
    id: exerciseId,
    name: '$displayName (Placeholder)',
    category: ExerciseCategory.technique,
    sets: 3,
    reps: 12,
    duration: 45,
    rest: 30,
    youtubeQuery: 'hockey training $displayName',
  );
}

String _humanizeId(String rawId) {
  final cleaned = rawId.replaceAll(RegExp(r'[-_]+'), ' ').trim();
  if (cleaned.isEmpty) {
    return 'Exercise';
  }

  final words = cleaned.split(' ');
  final capitalized = words
      .where((word) => word.isNotEmpty)
      .map((word) =>
          word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : ''))
      .join(' ');

  return capitalized;
}
