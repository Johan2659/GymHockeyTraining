import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/repositories/session_repository.dart';
import '../datasources/local_session_source.dart';

/// Implementation of SessionRepository using local data source
class SessionRepositoryImpl implements SessionRepository {
  final LocalSessionSource _localSource;
  static final _logger = Logger();

  SessionRepositoryImpl({
    LocalSessionSource? localSource,
  }) : _localSource = localSource ?? LocalSessionSource();

  @override
  Future<Session?> getById(String id) async {
    try {
      _logger.d('SessionRepositoryImpl: Getting session by ID: $id');
      
      final session = await _localSource.getSessionById(id);
      
      if (session != null) {
        _logger.i('SessionRepositoryImpl: Found session: ${session.title}');
      } else {
        _logger.w('SessionRepositoryImpl: Session not found: $id');
      }
      
      return session;
      
    } catch (e, stackTrace) {
      _logger.e('SessionRepositoryImpl: Failed to get session $id', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<List<Session>> getByProgramId(String programId) async {
    try {
      _logger.d('SessionRepositoryImpl: Getting sessions for program: $programId');
      
      final sessions = await _localSource.getSessionsByProgramId(programId);
      
      _logger.i('SessionRepositoryImpl: Found ${sessions.length} sessions for program $programId');
      return sessions;
      
    } catch (e, stackTrace) {
      _logger.e('SessionRepositoryImpl: Failed to get sessions for program $programId', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Session>> getByWeek(String programId, int week) async {
    try {
      _logger.d('SessionRepositoryImpl: Getting sessions for program $programId, week $week');
      
      final sessions = await _localSource.getSessionsByWeek(programId, week);
      
      _logger.i('SessionRepositoryImpl: Found ${sessions.length} sessions for week $week');
      return sessions;
      
    } catch (e, stackTrace) {
      _logger.e('SessionRepositoryImpl: Failed to get sessions for week $week', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
