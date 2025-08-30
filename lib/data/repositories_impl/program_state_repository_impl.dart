import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/repositories/program_state_repository.dart';
import '../datasources/local_prefs_source.dart';

/// Implementation of ProgramStateRepository using local data source
class ProgramStateRepositoryImpl implements ProgramStateRepository {
  final LocalPrefsSource _localSource;
  static final _logger = Logger();

  ProgramStateRepositoryImpl({
    LocalPrefsSource? localSource,
  }) : _localSource = localSource ?? LocalPrefsSource();

  @override
  Future<ProgramState?> get() async {
    try {
      _logger.d('ProgramStateRepositoryImpl: Getting program state');
      
      final state = await _localSource.getProgramState();
      
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
        _logger.i('ProgramStateRepositoryImpl: Successfully saved program state');
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
  Stream<ProgramState?> watch() {
    try {
      _logger.d('ProgramStateRepositoryImpl: Creating watch stream for program state');
      return _localSource.watchProgramState();
    } catch (e, stackTrace) {
      _logger.e('ProgramStateRepositoryImpl: Error creating watch stream', 
                error: e, stackTrace: stackTrace);
      return Stream.value(null);
    }
  }

  @override
  Future<bool> clear() async {
    try {
      _logger.w('ProgramStateRepositoryImpl: Clearing program state');
      
      final success = await _localSource.clearProgramState();
      
      if (success) {
        _logger.w('ProgramStateRepositoryImpl: Successfully cleared program state');
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
      _logger.d('ProgramStateRepositoryImpl: Updating current session to $session');
      
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
      _logger.d('ProgramStateRepositoryImpl: Adding completed exercise: $exerciseId');
      
      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to update');
        return false;
      }
      
      final updatedCompletedIds = List<String>.from(currentState.completedExerciseIds);
      if (!updatedCompletedIds.contains(exerciseId)) {
        updatedCompletedIds.add(exerciseId);
      }
      
      final updatedState = currentState.copyWith(completedExerciseIds: updatedCompletedIds);
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
      _logger.d('ProgramStateRepositoryImpl: Removing completed exercise: $exerciseId');
      
      final currentState = await get();
      if (currentState == null) {
        _logger.w('ProgramStateRepositoryImpl: No current state to update');
        return false;
      }
      
      final updatedCompletedIds = List<String>.from(currentState.completedExerciseIds);
      updatedCompletedIds.remove(exerciseId);
      
      final updatedState = currentState.copyWith(completedExerciseIds: updatedCompletedIds);
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
}
