import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../app/di.dart';
import '../../../core/models/models.dart';
import 'session_preview_model.dart';

final _logger = Logger();

/// Provides a [ResolvedSession] with exercises loaded from the database.
<<<<<<< HEAD
/// Takes a tuple of (programId, week, sessionIndex) as the family parameter.
final resolvedSessionProvider = FutureProvider.autoDispose
    .family<ResolvedSession?, (String, int, int)>((ref, params) async {
  final (programId, week, sessionIndex) = params;

=======
final resolvedSessionProvider = FutureProvider.autoDispose
    .family<ResolvedSession?, (String, int, int)>((ref, params) async {
  final (programId, week, sessionIndex) = params;
  
>>>>>>> b3d69919293f86865060415829b2d128c5028820
  final programRepository = ref.watch(programRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  final exerciseRepository = ref.watch(exerciseRepositoryProvider);

  // Get the program to find the session ID
  final program = await programRepository.getById(programId);
  if (program == null) {
<<<<<<< HEAD
    _logger.w(
        'resolvedSessionProvider: Program not found (programId: $programId)');
=======
    _logger.w('resolvedSessionProvider: Program not found (programId: $programId)');
>>>>>>> b3d69919293f86865060415829b2d128c5028820
    return null;
  }

  if (week >= program.weeks.length) {
<<<<<<< HEAD
    _logger.w(
        'resolvedSessionProvider: Week index $week is out of bounds for program $programId');
=======
    _logger.w('resolvedSessionProvider: Week index $week is out of bounds for program $programId');
>>>>>>> b3d69919293f86865060415829b2d128c5028820
    return null;
  }

  final weekData = program.weeks[week];
  if (sessionIndex >= weekData.sessions.length) {
<<<<<<< HEAD
    _logger.w(
        'resolvedSessionProvider: Session index $sessionIndex is out of bounds for week $week in program $programId');
=======
    _logger.w('resolvedSessionProvider: Session index $sessionIndex is out of bounds for week $week');
>>>>>>> b3d69919293f86865060415829b2d128c5028820
    return null;
  }

  final sessionId = weekData.sessions[sessionIndex];
<<<<<<< HEAD

  // Get the session
  final session = await sessionRepository.getById(sessionId);
  if (session == null) {
    _logger
        .w('resolvedSessionProvider: Session not found (sessionId: $sessionId)');
=======
  final session = await sessionRepository.getById(sessionId);
  if (session == null) {
    _logger.w('resolvedSessionProvider: Session not found (sessionId: $sessionId)');
>>>>>>> b3d69919293f86865060415829b2d128c5028820
    return null;
  }

  final placeholderIds = <String>{};
  final exercises = <Exercise>[];

<<<<<<< HEAD
  // Resolve all exercises
=======
>>>>>>> b3d69919293f86865060415829b2d128c5028820
  for (final block in session.blocks) {
    final exercise = await exerciseRepository.getById(block.exerciseId);
    if (exercise != null) {
      exercises.add(exercise);
    } else {
      placeholderIds.add(block.exerciseId);
      final placeholder = _createPlaceholderExercise(block.exerciseId);
      exercises.add(placeholder);

      _logger.w(
        'resolvedSessionProvider: Using placeholder exercise (sessionId: $sessionId, exerciseId: ${block.exerciseId})',
      );
    }
  }

  return ResolvedSession(
    session: session,
    exercises: exercises,
    placeholderExerciseIds: placeholderIds,
    programId: programId,
    week: week,
    sessionIndex: sessionIndex,
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
<<<<<<< HEAD
=======

>>>>>>> b3d69919293f86865060415829b2d128c5028820
