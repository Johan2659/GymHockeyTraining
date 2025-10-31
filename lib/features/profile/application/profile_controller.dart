import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
import '../../../core/models/models.dart';
import '../../../core/persistence/persistence_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/storage/hive_boxes.dart';
import '../../../core/storage/local_kv_store.dart';

part 'profile_controller.g.dart';

/// Profile controller for managing user profile and settings
@riverpod
class ProfileController extends _$ProfileController {
  @override
  void build() {
    // Initialize profile state
  }

  /// Updates the user role
  Future<bool> updateRole(UserRole role) async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.updateRole(role);
  }

  /// Updates the units setting
  Future<bool> updateUnits(String units) async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.updateUnits(units);
  }

  /// Updates the language setting
  Future<bool> updateLanguage(String language) async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.updateLanguage(language);
  }

  /// Updates the theme setting
  Future<bool> updateTheme(String theme) async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.updateTheme(theme);
  }

  /// Exports all logs to a JSON file
  Future<String?> exportLogs() async {
    try {
      LoggerService.instance
          .info('Starting log export', source: 'ProfileController');

      // Export using LoggerService
      await LoggerService.instance.exportLogs();

      // Also include progress events in a separate file for comprehensive export
      final progressRepo = ref.read(progressRepositoryProvider);
      final events = await progressRepo.getRecent(
          limit: 1000); // Get all events with high limit

      // Create export data structure for progress events
      final exportData = {
        'export_timestamp': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'total_events': events.length,
        'events': events.map((event) => event.toJson()).toList(),
      };

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'hockey_gym_progress_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // Write file
      await file.writeAsString(jsonString);

      LoggerService.instance.info('Logs exported successfully',
          source: 'ProfileController', metadata: {'fileName': fileName});
      PersistenceService.logStateChange('Logs exported to $fileName');
      return file.path;
    } catch (e, stackTrace) {
      LoggerService.instance.error('Failed to export logs',
          source: 'ProfileController', error: e, stackTrace: stackTrace);
      if (kDebugMode) {
        print('Error exporting logs: $e');
      }
      return null;
    }
  }

  /// Deletes all user data and account (wipes Hive boxes)
  Future<bool> deleteAccount() async {
    try {
      // Clear all Hive boxes
      final boxNames = HiveBoxes.allBoxes;
      bool allSuccess = true;

      for (final boxName in boxNames) {
        try {
          final success = await LocalKVStore.clear(boxName);
          if (!success) {
            allSuccess = false;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error clearing box $boxName: $e');
          }
          allSuccess = false;
        }
      }

      // Also clear via PersistenceService to handle fallbacks
      await PersistenceService.clearAll();

      if (allSuccess) {
        PersistenceService.logStateChange('Account deleted - all data wiped');
      }

      return allSuccess;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      return false;
    }
  }
}
