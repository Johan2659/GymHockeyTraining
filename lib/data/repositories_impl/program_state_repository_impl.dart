import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import '../../core/repositories/program_state_repository.dart';
import '../../core/repositories/auth_repository.dart';
import '../datasources/local_prefs_source.dart';

/// Implementation of ProgramStateRepository using local data source
class ProgramStateRepositoryImpl implements ProgramStateRepository {
  final LocalPrefsSource _localSource;
  final AuthRepository _authRepository;
  static final _logger = AppLogger.getLogger();

  ProgramStateRepositoryImpl({
    LocalPrefsSource? localSource,
    required AuthRepository authRepository,
  })  : _localSource = localSource ?? LocalPrefsSource(),
        _authRepository = authRepository;

  @override
  Future<ProgramState?> get() async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Getting program state');

      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';

      final state = await _localSource.getProgramState(userId);

      if (state != null) {
        _logger.i('ProgramStateRepositoryImpl: Found program state');
      } else {
        _logger.d('ProgramStateRepositoryImpl: No program state found');
      }

      return state;
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Failed to get program state',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> save(ProgramState state) async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Saving program state');

      final success = await _localSource.saveProgramState(state);

      if (success) {
        _logger
            .i('ProgramStateRepositoryImpl: Successfully saved program state');
      } else {
        _logger.e('ProgramStateRepositoryImpl: Failed to save program state');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error saving program state',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Stream<ProgramState?> watch() async* {
    try {
      _logger.d(
          'ProgramStateRepositoryImpl: Creating watch stream for program state');
      
      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';
      
      yield* _localSource.watchProgramState(userId);
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error creating watch stream',
          error: e, stackTrace: stackTrace);
      yield null;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      _logger.w('ProgramStateRepositoryImpl: Clearing program state');

      final currentUser = await _authRepository.getCurrentUser();
      final userId = currentUser?.id ?? '';

      final success = await _localSource.clearProgramState(userId);

      if (success) {
        _logger.w(
            'ProgramStateRepositoryImpl: Successfully cleared program state');
      } else {
        _logger.e('ProgramStateRepositoryImpl: Failed to clear program state');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error clearing program state',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> updateCurrentWeek(int week) async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Updating current week to $week');

      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to update');
        return false;
      }

      final updatedState = currentState.copyWith(currentWeek: week);
      return await save(updatedState);
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error updating current week',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> updateCurrentSession(int session) async {
    try {
      _logger.d(
          'ProgramStateRepositoryImpl: Updating current session to $session');

      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to update');
        return false;
      }

      final updatedState = currentState.copyWith(currentSession: session);
      return await save(updatedState);
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error updating current session',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> addCompletedExercise(String exerciseId) async {
    try {
      _logger.d(
          'ProgramStateRepositoryImpl: Adding completed exercise: $exerciseId');

      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to update');
        return false;
      }

      final updatedCompletedIds =
          List<String>.from(currentState.completedExerciseIds);
      if (!updatedCompletedIds.contains(exerciseId)) {
        updatedCompletedIds.add(exerciseId);
      }

      final updatedState =
          currentState.copyWith(completedExerciseIds: updatedCompletedIds);
      return await save(updatedState);
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error adding completed exercise',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> removeCompletedExercise(String exerciseId) async {
    try {
      _logger.d(
          'ProgramStateRepositoryImpl: Removing completed exercise: $exerciseId');

      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to update');
        return false;
      }

      final updatedCompletedIds =
          List<String>.from(currentState.completedExerciseIds);
      updatedCompletedIds.remove(exerciseId);

      final updatedState =
          currentState.copyWith(completedExerciseIds: updatedCompletedIds);
      return await save(updatedState);
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error removing completed exercise',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> pauseProgram() async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Pausing program');

      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to pause');
        return false;
      }

      final updatedState = currentState.copyWith(pausedAt: DateTime.now());
      return await save(updatedState);
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error pausing program',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> resumeProgram() async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Resuming program');

      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to resume');
        return false;
      }

      final updatedState = currentState.copyWith(pausedAt: null);
      return await save(updatedState);
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error resuming program',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> saveSessionInProgress(SessionInProgress session) async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Saving session in progress');

      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to update');
        return false;
      }

      final updatedState = currentState.copyWith(sessionInProgress: session);
      final success = await save(updatedState);

      if (success) {
        _logger.i(
            'ProgramStateRepositoryImpl: Successfully saved session in progress');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error saving session in progress',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> clearSessionInProgress() async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Clearing session in progress');

      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to update');
        return false;
      }

      final updatedState = currentState.copyWith(clearSessionInProgress: true);
      final success = await save(updatedState);

      if (success) {
        _logger.i(
            'ProgramStateRepositoryImpl: Successfully cleared session in progress');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e(
          'ProgramStateRepositoryImpl: Error clearing session in progress',
          error: e,
          stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<SessionInProgress?> getSessionInProgress() async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Getting session in progress');

      final currentState = await get();
      if (currentState == null) {
        _logger.d('ProgramStateRepositoryImpl: No current state found');
        return null;
      }

      final session = currentState.sessionInProgress;
      if (session != null) {
        _logger.i('ProgramStateRepositoryImpl: Found session in progress');
      } else {
        _logger.d('ProgramStateRepositoryImpl: No session in progress found');
      }

      return session;
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error getting session in progress',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
