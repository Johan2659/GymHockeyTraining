import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';

import '../../../app/di.dart';
import '../../../core/models/models.dart';
import '../../application/app_state_provider.dart';

part 'program_management_controller.g.dart';

/// Enum for different deletion options
enum ProgramDeletionOption {
  /// Stop program but keep all progress data
  stopOnly,
  /// Stop program and delete progress stats for this program only
  stopAndDeleteProgress,
  /// Stop program and delete everything (progress + program state)
  stopAndDeleteEverything,
}

/// Service for managing program lifecycle operations
/// Handles stopping and deleting programs while maintaining SSOT
class ProgramManagementService {
  static final _logger = Logger();

  /// Stops and optionally deletes the current active program
  /// Returns true if operation was successful
  static Future<bool> stopCurrentProgram({
    required WidgetRef ref,
    required ProgramDeletionOption option,
  }) async {
    try {
      _logger.i('ProgramManagementService: Stopping current program with option: $option');
      
      // Get current program state to know which program to delete
      final programStateRepo = ref.read(programStateRepositoryProvider);
      final currentState = await programStateRepo.get();
      
      if (currentState?.activeProgramId == null) {
        _logger.w('ProgramManagementService: No active program to stop');
        return false;
      }
      
      final activeProgramId = currentState!.activeProgramId!;
      _logger.d('ProgramManagementService: Active program ID: $activeProgramId');
      
      bool success = true;
      
      // Handle different deletion options
      switch (option) {
        case ProgramDeletionOption.stopOnly:
          success = await _stopProgramOnly(ref);
          break;
        case ProgramDeletionOption.stopAndDeleteProgress:
          success = await _stopAndDeleteProgress(ref, activeProgramId);
          break;
        case ProgramDeletionOption.stopAndDeleteEverything:
          success = await _stopAndDeleteEverything(ref, activeProgramId);
          break;
      }
      
      if (success) {
        _logger.i('ProgramManagementService: Successfully stopped program with option: $option');
        
        // Invalidate relevant providers to trigger UI updates
        ref.invalidate(progressEventsProvider);
        ref.invalidate(programStateProvider);
        ref.invalidate(performanceAnalyticsProvider);
        ref.invalidate(currentXPProvider);
        ref.invalidate(todayXPProvider);
        ref.invalidate(currentStreakProvider);
        ref.invalidate(activeProgramProvider);
        ref.invalidate(appStateProvider);
      } else {
        _logger.e('ProgramManagementService: Failed to stop program with option: $option');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      _logger.e('ProgramManagementService: Error stopping program', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }
  
  /// Gets the current active program details for display
  static Future<Program?> getCurrentProgram(WidgetRef ref) async {
    try {
      final programStateRepo = ref.read(programStateRepositoryProvider);
      final currentState = await programStateRepo.get();
      
      if (currentState?.activeProgramId == null) {
        return null;
      }
      
      final programRepo = ref.read(programRepositoryProvider);
      return await programRepo.getById(currentState!.activeProgramId!);
      
    } catch (e, stackTrace) {
      _logger.e('ProgramManagementService: Error getting current program', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Gets progress statistics for the current active program
  static Future<int> getCurrentProgramProgressEventCount(WidgetRef ref) async {
    try {
      final programStateRepo = ref.read(programStateRepositoryProvider);
      final currentState = await programStateRepo.get();
      
      if (currentState?.activeProgramId == null) {
        return 0;
      }
      
      final progressRepo = ref.read(progressRepositoryProvider);
      final events = await progressRepo.getByProgram(currentState!.activeProgramId!);
      
      return events.length;
      
    } catch (e, stackTrace) {
      _logger.e('ProgramManagementService: Error getting progress count', 
                error: e, stackTrace: stackTrace);
      return 0;
    }
  }

  // =============================================================================
  // PRIVATE METHODS
  // =============================================================================

  /// Option 1: Stop program only (clear program state, keep all progress)
  static Future<bool> _stopProgramOnly(WidgetRef ref) async {
    try {
      _logger.d('ProgramManagementService: Stopping program only');
      
      final programStateRepo = ref.read(programStateRepositoryProvider);
      final success = await programStateRepo.clear();
      
      if (success) {
        _logger.i('ProgramManagementService: Successfully cleared program state');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      _logger.e('ProgramManagementService: Error stopping program only', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Option 2: Stop program and delete its progress data
  static Future<bool> _stopAndDeleteProgress(WidgetRef ref, String programId) async {
    try {
      _logger.d('ProgramManagementService: Stopping program and deleting progress for: $programId');
      
      final programStateRepo = ref.read(programStateRepositoryProvider);
      final progressRepo = ref.read(progressRepositoryProvider);
      final analyticsRepo = ref.read(performanceAnalyticsRepositoryProvider);
      
      // Delete progress events for this program
      final progressDeleted = await progressRepo.deleteByProgram(programId);
      
      // Clear program state
      final stateCleared = await programStateRepo.clear();
      
      // Clear performance analytics (since they're derived from progress events)
      final analyticsCleared = await analyticsRepo.clear();
      
      final success = progressDeleted && stateCleared && analyticsCleared;
      
      if (success) {
        _logger.i('ProgramManagementService: Successfully deleted progress, cleared state, and reset analytics');
      } else {
        _logger.e('ProgramManagementService: Failed to delete progress, clear state, or reset analytics');
      }
      
      return success;
      
    } catch (e, stackTrace) {
      _logger.e('ProgramManagementService: Error stopping and deleting progress', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Option 3: Stop program and delete everything (progress + state)
  static Future<bool> _stopAndDeleteEverything(WidgetRef ref, String programId) async {
    try {
      _logger.d('ProgramManagementService: Stopping program and deleting everything for: $programId');
      
      // This is the same as option 2 since we're already clearing the program state
      // The "everything" refers to both progress events and the active program state
      return await _stopAndDeleteProgress(ref, programId);
      
    } catch (e, stackTrace) {
      _logger.e('ProgramManagementService: Error stopping and deleting everything', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }
}

/// Provider for current active program information
@riverpod
Future<Program?> currentActiveProgram(Ref ref) async {
  try {
    final programStateRepo = ref.read(programStateRepositoryProvider);
    final currentState = await programStateRepo.get();
    
    if (currentState?.activeProgramId == null) {
      return null;
    }
    
    final programRepo = ref.read(programRepositoryProvider);
    return await programRepo.getById(currentState!.activeProgramId!);
    
  } catch (e, stackTrace) {
    final _logger = Logger();
    _logger.e('currentActiveProgramProvider: Error getting current program', 
              error: e, stackTrace: stackTrace);
    return null;
  }
}

/// Provider for current program progress event count
@riverpod
Future<int> currentProgramProgressCount(Ref ref) async {
  try {
    final programStateRepo = ref.read(programStateRepositoryProvider);
    final currentState = await programStateRepo.get();
    
    if (currentState?.activeProgramId == null) {
      return 0;
    }
    
    final progressRepo = ref.read(progressRepositoryProvider);
    final events = await progressRepo.getByProgram(currentState!.activeProgramId!);
    
    return events.length;
    
  } catch (e, stackTrace) {
    final _logger = Logger();
    _logger.e('currentProgramProgressCountProvider: Error getting progress count', 
              error: e, stackTrace: stackTrace);
    return 0;
  }
}
