import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import 'attacker_program_data.dart';
import 'defender_program_data.dart';
import 'goalie_program_data.dart';
import 'referee_program_data.dart';

/// Local data source for static program definitions
/// Loads programs from dedicated program data classes
class LocalProgramSource {
  static final _logger = Logger();

  // Static data removed - all programs now use dedicated data classes

  /// Gets all available programs
  Future<List<Program>> getAllPrograms() async {
    try {
      _logger.d('LocalProgramSource: Loading all programs');

      final programs = <Program>[];

      // Load attacker program
      final attackerProgram = await AttackerProgramData.getAttackerProgram();
      if (attackerProgram != null) {
        programs.add(attackerProgram);
      }

      // Load defender program
      final defenderProgram = await DefenderProgramData.getDefenderProgram();
      if (defenderProgram != null) {
        programs.add(defenderProgram);
      }

      // Load goalie program
      final goalieProgram = await GoalieProgramData.getGoalieProgram();
      if (goalieProgram != null) {
        programs.add(goalieProgram);
      }

      // Load referee program
      final refereeProgram = await RefereeProgramData.getRefereeProgram();
      if (refereeProgram != null) {
        programs.add(refereeProgram);
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

      switch (id) {
        case 'hockey_attacker_2025':
          return await AttackerProgramData.getAttackerProgram();
        case 'hockey_defender_2025':
          return await DefenderProgramData.getDefenderProgram();
        case 'hockey_goalie_2025':
          return await GoalieProgramData.getGoalieProgram();
        case 'hockey_referee_2025':
          return await RefereeProgramData.getRefereeProgram();
        default:
          _logger.w('LocalProgramSource: Program not found: $id');
          return null;
      }
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
      final filteredPrograms =
          allPrograms.where((program) => program.role == role).toList();

      _logger.d(
          'LocalProgramSource: Found ${filteredPrograms.length} programs for role $role');
      return filteredPrograms;
    } catch (e, stackTrace) {
      _logger.e('LocalProgramSource: Failed to load programs for role $role',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
