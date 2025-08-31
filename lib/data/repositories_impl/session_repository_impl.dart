import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/repositories/session_repository.dart';
import '../../core/services/logger_service.dart';
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
      LoggerService.instance.debug('Getting session by ID: $id', source: 'SessionRepositoryImpl');
      _logger.d('SessionRepositoryImpl: Getting session by ID: $id');
      
      final session = await _localSource.getSessionById(id);
      
      if (session != null) {
        LoggerService.instance.info('Found session: ${session.title}', 
          source: 'SessionRepositoryImpl', metadata: {'sessionId': id});
        _logger.i('SessionRepositoryImpl: Found session: ${session.title}');
      } else {
        LoggerService.instance.warning('Session not found: $id', source: 'SessionRepositoryImpl');
        _logger.w('SessionRepositoryImpl: Session not found: $id');
      }
      
      return session;
      
    } catch (e, stackTrace) {
      LoggerService.instance.error('Failed to get session', 
        source: 'SessionRepositoryImpl', error: e, stackTrace: stackTrace,
        metadata: {'sessionId': id});
      _logger.e('SessionRepositoryImpl: Failed to get session $id', 
                error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<List<Session>> getByProgramId(String programId) async {
    try {
      LoggerService.instance.debug('Getting sessions for program: $programId', source: 'SessionRepositoryImpl');
      _logger.d('SessionRepositoryImpl: Getting sessions for program: $programId');
      
      final sessions = await _localSource.getSessionsByProgramId(programId);
      
      LoggerService.instance.info('Found ${sessions.length} sessions for program', 
        source: 'SessionRepositoryImpl', metadata: {'programId': programId, 'sessionCount': sessions.length});
      _logger.i('SessionRepositoryImpl: Found ${sessions.length} sessions for program $programId');
      return sessions;
      
    } catch (e, stackTrace) {
      LoggerService.instance.error('Failed to get sessions for program', 
        source: 'SessionRepositoryImpl', error: e, stackTrace: stackTrace,
        metadata: {'programId': programId});
      _logger.e('SessionRepositoryImpl: Failed to get sessions for program $programId', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<Session>> getByWeek(String programId, int week) async {
    try {
      LoggerService.instance.debug('Getting sessions for program $programId, week $week', source: 'SessionRepositoryImpl');
      _logger.d('SessionRepositoryImpl: Getting sessions for program $programId, week $week');
      
      final sessions = await _localSource.getSessionsByWeek(programId, week);
      
      LoggerService.instance.info('Found ${sessions.length} sessions for week $week', 
        source: 'SessionRepositoryImpl', metadata: {'programId': programId, 'week': week, 'sessionCount': sessions.length});
      _logger.i('SessionRepositoryImpl: Found ${sessions.length} sessions for week $week');
      return sessions;
      
    } catch (e, stackTrace) {
      LoggerService.instance.error('Failed to get sessions for week', 
        source: 'SessionRepositoryImpl', error: e, stackTrace: stackTrace,
        metadata: {'programId': programId, 'week': week});
      _logger.e('SessionRepositoryImpl: Failed to get sessions for week $week', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
