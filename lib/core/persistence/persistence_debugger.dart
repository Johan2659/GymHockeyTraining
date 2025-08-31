/// Debug utilities for persistence testing
library;

import 'package:logger/logger.dart';
import '../storage/local_kv_store.dart';
import '../storage/hive_boxes.dart';
import '../persistence/persistence_service.dart';

class PersistenceDebugger {
  static final _logger = Logger();

  /// Debug function to check what data is actually stored
  static Future<void> debugStoredData() async {
    _logger.i('🔍 === PERSISTENCE DEBUG ===');
    
    // Check Hive data
    try {
      final profileData = await LocalKVStore.read(HiveBoxes.profile, 'user_profile');
      final programData = await LocalKVStore.read(HiveBoxes.settings, 'program_state');
      
      _logger.i('🔍 Hive Profile Data: ${profileData != null ? 'EXISTS' : 'NULL'}');
      _logger.i('🔍 Hive Program Data: ${programData != null ? 'EXISTS' : 'NULL'}');
      
      if (profileData != null) {
        _logger.d('🔍 Profile Data: ${profileData.length} chars');
      }
      
      if (programData != null) {
        _logger.d('🔍 Program Data: ${programData.length} chars');
      }
      
    } catch (e) {
      _logger.e('🔍 Error reading Hive data: $e');
    }
    
    // Check PersistenceService fallback
    try {
      final fallbackProfile = await PersistenceService.readWithFallback(HiveBoxes.profile, 'user_profile');
      final fallbackProgram = await PersistenceService.readWithFallback(HiveBoxes.settings, 'program_state');
      
      _logger.i('🔍 Fallback Profile: ${fallbackProfile != null ? 'EXISTS' : 'NULL'}');
      _logger.i('🔍 Fallback Program: ${fallbackProgram != null ? 'EXISTS' : 'NULL'}');
      
    } catch (e) {
      _logger.e('🔍 Error reading fallback data: $e');
    }
    
    // Check schema version
    try {
      final schemaVersion = await PersistenceService.getSchemaVersion();
      _logger.i('🔍 Schema Version: $schemaVersion');
    } catch (e) {
      _logger.e('🔍 Error reading schema version: $e');
    }
    
    _logger.i('🔍 === END DEBUG ===');
  }

  /// Debug function to manually save test data
  static Future<void> saveTestData() async {
    _logger.i('🧪 Saving test data...');
    
    const testProfile = '{"name":"Test User","role":"attacker","preferences":{}}';
    const testProgram = '{"activeProgramId":"test_program","currentWeek":1,"currentSession":2,"completedExerciseIds":["ex1","ex2"]}';
    
    final profileSuccess = await PersistenceService.writeWithFallback(HiveBoxes.profile, 'user_profile', testProfile);
    final programSuccess = await PersistenceService.writeWithFallback(HiveBoxes.settings, 'program_state', testProgram);
    
    _logger.i('🧪 Test Profile Saved: $profileSuccess');
    _logger.i('🧪 Test Program Saved: $programSuccess');
  }
}
