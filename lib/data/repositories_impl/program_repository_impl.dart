import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/repositories/program_repository.dart';
import '../datasources/local_program_source.dart';

/// Implementation of ProgramRepository using local data source
class ProgramRepositoryImpl implements ProgramRepository {
  final LocalProgramSource _localSource;
  static final _logger = Logger();

  ProgramRepositoryImpl({
    LocalProgramSource? localSource,
  }) : _localSource = localSource ?? LocalProgramSource();

  @override
  Future<Program?> getById(String id) async {
    try {
      _logger.d('ProgramRepositoryImpl: Getting program by ID: $id');
      
      final program = await _localSource.getProgramById(id);
      
      if (program != null) {
        _logger.i('ProgramRepositoryImpl: Found program: ${program.title}');
      } else {
        _logger.w('ProgramRepositoryImpl: Program not found: $id');
      }
      
      return program;
      
    } catch (e, stackTrace) {
      _logger.e('ProgramRepositoryImpl: Failed to get program $id', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<List<Program>> listByRole(UserRole role) async {
    try {
      _logger.d('ProgramRepositoryImpl: Getting programs for role: $role');
      
      final programs = await _localSource.getProgramsByRole(role);
      
      _logger.i('ProgramRepositoryImpl: Found ${programs.length} programs for role $role');
      return programs;
      
    } catch (e, stackTrace) {
      _logger.e('ProgramRepositoryImpl: Failed to get programs for role $role', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Program>> getAll() async {
    try {
      _logger.d('ProgramRepositoryImpl: Getting all programs');
      
      final programs = await _localSource.getAllPrograms();
      
      _logger.i('ProgramRepositoryImpl: Found ${programs.length} total programs');
      return programs;
      
    } catch (e, stackTrace) {
      _logger.e('ProgramRepositoryImpl: Failed to get all programs', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
