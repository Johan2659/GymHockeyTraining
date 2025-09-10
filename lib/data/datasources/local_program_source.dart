import 'dart:convert';
import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import 'attacker_program_data.dart';

/// Local data source for static program definitions
/// Loads programs from embedded JSON data and dedicated program classes
class LocalProgramSource {
  static final _logger = Logger();
  
  // Static program data - in a real app this could be loaded from assets
  static const String _attackerProgramJson = '''
{
  "id": "hockey_attacker_v1",
  "role": "attacker",
  "title": "Hockey Attacker Training Program",
  "weeks": [
    {
      "index": 1,
      "sessions": [
        "week1_session1",
        "week1_session2", 
        "week1_session3"
      ]
    },
    {
      "index": 2,
      "sessions": [
        "week2_session1",
        "week2_session2",
        "week2_session3"
      ]
    }
  ]
}
''';

  /// Gets all available programs
  Future<List<Program>> getAllPrograms() async {
    try {
      _logger.d('LocalProgramSource: Loading all programs');
      
      final programs = <Program>[];
      
      // Load new attacker program
      final attackerProgram = await AttackerProgramData.getAttackerProgram();
      if (attackerProgram != null) {
        programs.add(attackerProgram);
      }
      
      // Load new defender program
      // TODO: Uncomment when DefenderProgramData is created
      // final defenderProgram = await DefenderProgramData.getDefenderProgram();
      // if (defenderProgram != null) {
      //   programs.add(defenderProgram);
      // }
      
      // Load legacy attacker program for compatibility
      final legacyAttackerProgram = await _loadLegacyAttackerProgram();
      if (legacyAttackerProgram != null) {
        programs.add(legacyAttackerProgram);
      }
      
      // Additional programs can be added here in the future
      
      _logger.i('LocalProgramSource: Loaded ${programs.length} programs');
      return programs;
      
    } catch (e, stackTrace) {
      _logger.e('LocalProgramSource: Failed to load programs', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific program by ID
  Future<Program?> getProgramById(String id) async {
    try {
      _logger.d('LocalProgramSource: Loading program with ID: $id');
      
      if (id == 'hockey_attacker_2025') {
        return await AttackerProgramData.getAttackerProgram();
      }
      
      if (id == 'hockey_attacker_v1') {
        return await _loadLegacyAttackerProgram();
      }
      
      _logger.w('LocalProgramSource: Program not found: $id');
      return null;
      
    } catch (e, stackTrace) {
      _logger.e('LocalProgramSource: Failed to load program $id', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Gets programs filtered by user role
  Future<List<Program>> getProgramsByRole(UserRole role) async {
    try {
      _logger.d('LocalProgramSource: Loading programs for role: $role');
      
      final allPrograms = await getAllPrograms();
      final filteredPrograms = allPrograms
          .where((program) => program.role == role)
          .toList();
      
      _logger.d('LocalProgramSource: Found ${filteredPrograms.length} programs for role $role');
      return filteredPrograms;
      
    } catch (e, stackTrace) {
      _logger.e('LocalProgramSource: Failed to load programs for role $role', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Loads the legacy attacker program from JSON
  Future<Program?> _loadLegacyAttackerProgram() async {
    try {
      final jsonData = jsonDecode(_attackerProgramJson) as Map<String, dynamic>;
      final program = Program.fromJson(jsonData);
      
      _logger.d('LocalProgramSource: Successfully loaded legacy attacker program');
      return program;
      
    } catch (e, stackTrace) {
      _logger.e('LocalProgramSource: Failed to parse legacy attacker program JSON', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
