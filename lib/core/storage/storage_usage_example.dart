import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../models/models.dart';
import 'hive_boxes.dart';
import 'local_kv_store.dart';
import 'migration_service.dart';
import 'secure_key_service.dart';

/// Example usage of the storage layer for domain models
/// This demonstrates how to use the encrypted Hive storage with JSON strings
class StorageUsageExample {
  static final _logger = Logger();

  /// Example: Store and retrieve a Program
  static Future<void> exampleProgramStorage() async {
    try {
      // Create a sample program
      final program = Program(
        id: 'program_001',
        name: 'Hockey Power Training',
        description: 'Strength and conditioning for hockey players',
        weeks: [
          Week(
            id: 'week_001',
            weekNumber: 1,
            name: 'Foundation Week',
            description: 'Building base strength',
            blocks: [
              ExerciseBlock(
                id: 'block_001',
                name: 'Warm-up',
                exercises: [
                  Exercise(
                    id: 'ex_001',
                    name: 'Push-ups',
                    sets: 3,
                    reps: 10,
                    weight: null,
                    restSeconds: 60,
                    description: 'Standard push-ups',
                  ),
                ],
              ),
            ],
          ),
        ],
        state: ProgramState.active,
      );

      // Convert to JSON and store
      final programJson = jsonEncode(program.toJson());
      final stored = await LocalKVStore.write(
        HiveBoxes.training,
        'current_program',
        programJson,
      );

      if (stored) {
        _logger.i('✅ Program stored successfully');
      } else {
        _logger.e('❌ Failed to store program');
        return;
      }

      // Retrieve and deserialize
      final retrievedJson = await LocalKVStore.read(
        HiveBoxes.training,
        'current_program',
      );

      if (retrievedJson != null) {
        final retrievedProgram = Program.fromJson(
          jsonDecode(retrievedJson) as Map<String, dynamic>,
        );
        _logger.i('✅ Program retrieved: ${retrievedProgram.name}');
        _logger.d('Program has ${retrievedProgram.weeks.length} weeks');
      } else {
        _logger.e('❌ Failed to retrieve program');
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Error in program storage example', error: e, stackTrace: stackTrace);
    }
  }

  /// Example: Store and retrieve progress events
  static Future<void> exampleProgressStorage() async {
    try {
      // Create sample progress events
      final events = [
        ProgressEvent(
          id: 'progress_001',
          timestamp: DateTime.now(),
          type: 'workout_completed',
          title: 'Completed Foundation Week - Day 1',
          description: 'Great session! Push-ups felt easier today.',
          metadata: {
            'program_id': 'program_001',
            'week_id': 'week_001',
            'exercises_completed': 5,
            'duration_minutes': 45,
          },
        ),
        ProgressEvent(
          id: 'progress_002',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: 'measurement',
          title: 'Weight Check',
          description: 'Weekly weigh-in',
          metadata: {
            'weight_kg': 75.5,
            'body_fat_percent': 12.3,
          },
        ),
      ];

      // Store each event
      for (final event in events) {
        final eventJson = jsonEncode(event.toJson());
        final stored = await LocalKVStore.write(
          HiveBoxes.progress,
          event.id,
          eventJson,
        );

        if (stored) {
          _logger.i('✅ Progress event stored: ${event.title}');
        } else {
          _logger.e('❌ Failed to store progress event: ${event.id}');
        }
      }

      // Retrieve all progress event keys
      final keys = await LocalKVStore.getKeys(HiveBoxes.progress);
      _logger.i('📊 Found ${keys.length} progress events');

      // Retrieve and display each event
      for (final key in keys) {
        final eventJson = await LocalKVStore.read(HiveBoxes.progress, key);
        if (eventJson != null) {
          final event = ProgressEvent.fromJson(
            jsonDecode(eventJson) as Map<String, dynamic>,
          );
          _logger.d('📝 Event: ${event.title} (${event.type})');
        }
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Error in progress storage example', error: e, stackTrace: stackTrace);
    }
  }

  /// Example: Store and retrieve user profile
  static Future<void> exampleProfileStorage() async {
    try {
      // Create sample profile
      final profile = Profile(
        id: 'user_001',
        name: 'Alex Johnson',
        email: 'alex.johnson@example.com',
        role: UserRole.athlete,
        xp: XP(
          totalPoints: 1250,
          level: 5,
          pointsToNextLevel: 250,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      // Store profile
      final profileJson = jsonEncode(profile.toJson());
      final stored = await LocalKVStore.write(
        HiveBoxes.profile,
        'current_user',
        profileJson,
      );

      if (stored) {
        _logger.i('✅ Profile stored successfully');
      } else {
        _logger.e('❌ Failed to store profile');
        return;
      }

      // Retrieve profile
      final retrievedJson = await LocalKVStore.read(
        HiveBoxes.profile,
        'current_user',
      );

      if (retrievedJson != null) {
        final retrievedProfile = Profile.fromJson(
          jsonDecode(retrievedJson) as Map<String, dynamic>,
        );
        _logger.i('✅ Profile retrieved: ${retrievedProfile.name}');
        _logger.d('User level: ${retrievedProfile.xp.level}, XP: ${retrievedProfile.xp.totalPoints}');
      } else {
        _logger.e('❌ Failed to retrieve profile');
      }
    } catch (e, stackTrace) {
      _logger.e('💥 Error in profile storage example', error: e, stackTrace: stackTrace);
    }
  }

  /// Run all storage examples
  static Future<void> runAllExamples() async {
    try {
      _logger.i('🚀 Running storage examples...');

      await exampleProgramStorage();
      await exampleProgressStorage();
      await exampleProfileStorage();

      _logger.i('✅ All storage examples completed');
    } catch (e, stackTrace) {
      _logger.e('💥 Error running storage examples', error: e, stackTrace: stackTrace);
    }
  }

  /// Example initialization and cleanup
  static Future<void> initializeStorageExample() async {
    try {
      _logger.i('🔧 Initializing storage for examples...');

      // Initialize Hive (normally done in main.dart)
      await Hive.initFlutter();

      // Get encryption key
      final encryptionKey = await SecureKeyService.getOrCreateEncryptionKey();
      final cipher = HiveAesCipher(encryptionKey);

      // Open boxes
      for (final boxName in HiveBoxes.allBoxes) {
        if (!Hive.isBoxOpen(boxName)) {
          await Hive.openBox(boxName, encryptionCipher: cipher);
        }
      }

      // Run migrations
      await MigrationService.ensureMigrations();

      _logger.i('✅ Storage initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('💥 Failed to initialize storage', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
