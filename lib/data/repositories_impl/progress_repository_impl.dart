import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/repositories/progress_repository.dart';
import '../../core/services/logger_service.dart';
import '../datasources/local_progress_source.dart';

/// Implementation of ProgressRepository using local data source
class ProgressRepositoryImpl implements ProgressRepository {
  final LocalProgressSource _localSource;
  static final _logger = Logger();

  ProgressRepositoryImpl({
    LocalProgressSource? localSource,
  }) : _localSource = localSource ?? LocalProgressSource();

  @override
  Future<bool> appendEvent(ProgressEvent event) async {
    try {
      LoggerService.instance.debug('Appending progress event: ${event.type}',
          source: 'ProgressRepositoryImpl',
          metadata: {
            'eventType': event.type.toString(),
            'programId': event.programId,
            'week': event.week,
            'session': event.session,
          });
      _logger.d('ProgressRepositoryImpl: Appending event: ${event.type}');

      final success = await _localSource.appendEvent(event);

      if (success) {
        LoggerService.instance.info('Successfully appended progress event',
            source: 'ProgressRepositoryImpl',
            metadata: {'eventType': event.type.toString()});
        _logger
            .i('ProgressRepositoryImpl: Successfully appended progress event');
      } else {
        LoggerService.instance.warning('Failed to append progress event',
            source: 'ProgressRepositoryImpl',
            metadata: {'eventType': event.type.toString()});
        _logger.e('ProgressRepositoryImpl: Failed to append progress event');
      }

      return success;
    } catch (e, stackTrace) {
      LoggerService.instance.error('Error appending progress event',
          source: 'ProgressRepositoryImpl',
          error: e,
          stackTrace: stackTrace,
          metadata: {'eventType': event.type.toString()});
      _logger.e('ProgressRepositoryImpl: Error appending progress event',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Stream<List<ProgressEvent>> watchAll() {
    try {
      _logger.d('ProgressRepositoryImpl: Creating watch stream for all events');
      return _localSource.watchAllEvents();
    } catch (e, stackTrace) {
      _logger.e('ProgressRepositoryImpl: Error creating watch stream',
          error: e, stackTrace: stackTrace);
      return Stream.value([]);
    }
  }

  @override
  Future<List<ProgressEvent>> getByProgram(String programId) async {
    try {
      _logger
          .d('ProgressRepositoryImpl: Getting events for program: $programId');

      final events = await _localSource.getEventsByProgram(programId);

      _logger.i(
          'ProgressRepositoryImpl: Found ${events.length} events for program $programId');
      return events;
    } catch (e, stackTrace) {
      _logger.e(
          'ProgressRepositoryImpl: Failed to get events for program $programId',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<ProgressEvent>> getByDateRange(
      DateTime start, DateTime end) async {
    try {
      _logger.d('ProgressRepositoryImpl: Getting events from $start to $end');

      final events = await _localSource.getEventsByDateRange(start, end);

      _logger.i(
          'ProgressRepositoryImpl: Found ${events.length} events in date range');
      return events;
    } catch (e, stackTrace) {
      _logger.e('ProgressRepositoryImpl: Failed to get events for date range',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<ProgressEvent>> getRecent({int limit = 50}) async {
    try {
      _logger.d('ProgressRepositoryImpl: Getting $limit recent events');

      final events = await _localSource.getRecentEvents(limit: limit);

      _logger.i('ProgressRepositoryImpl: Found ${events.length} recent events');
      return events;
    } catch (e, stackTrace) {
      _logger.e('ProgressRepositoryImpl: Failed to get recent events',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<bool> clearAll() async {
    try {
      _logger.w('ProgressRepositoryImpl: Clearing all progress events');

      final success = await _localSource.clearAllEvents();

      if (success) {
        _logger.w('ProgressRepositoryImpl: Successfully cleared all events');
      } else {
        _logger.e('ProgressRepositoryImpl: Failed to clear all events');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e('ProgressRepositoryImpl: Error clearing all events',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> deleteByProgram(String programId) async {
    try {
      _logger
          .w('ProgressRepositoryImpl: Deleting events for program: $programId');

      final success = await _localSource.deleteEventsByProgram(programId);

      if (success) {
        _logger.w(
            'ProgressRepositoryImpl: Successfully deleted events for program $programId');
      } else {
        _logger.e(
            'ProgressRepositoryImpl: Failed to delete events for program $programId');
      }

      return success;
    } catch (e, stackTrace) {
      _logger.e(
          'ProgressRepositoryImpl: Error deleting events for program $programId',
          error: e,
          stackTrace: stackTrace);
      return false;
    }
  }
}
