import 'dart:async';
import 'dart:convert';
import '../../core/logging/logger_config.dart';
import '../../core/models/models.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/storage/local_kv_store.dart';

/// Local data source for progress events using Hive storage
/// Provides append-only journaling with streaming capabilities
class LocalProgressSource {
  static final _logger = AppLogger.getLogger();
  static const String _progressKeyPrefix = 'progress_';
  static const String _counterKey = 'progress_counter';

  // Stream controller for watching progress changes
  static final _progressController =
      StreamController<List<ProgressEvent>>.broadcast();

  /// Appends a new progress event to storage
  Future<bool> appendEvent(ProgressEvent event) async {
    try {
      // Generate unique key using timestamp and counter
      final counter = await _getNextCounter();
      final key =
          '$_progressKeyPrefix${event.ts.millisecondsSinceEpoch}_$counter';

      // Store event as JSON
      final eventJson = jsonEncode(event.toJson());
      final success = await LocalKVStore.write(
        HiveBoxes.progress,
        key,
        eventJson,
      );

      if (success) {
        _logger.i('LocalProgressSource: Successfully appended progress event');
        // Notify stream listeners
        _notifyProgressChanged();
        return true;
      } else {
        _logger.e('LocalProgressSource: Failed to store progress event');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('LocalProgressSource: Error appending progress event',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Gets all progress events sorted by timestamp
  Future<List<ProgressEvent>> getAllEvents() async {
    try {
      final keys = await LocalKVStore.getKeys(HiveBoxes.progress);
      final progressKeys = keys
          .where(
              (key) => key.startsWith(_progressKeyPrefix) && key != _counterKey)
          .toList();

      final events = <ProgressEvent>[];

      // Use bulk read for better performance
      final eventJsonMap =
          await LocalKVStore.readBulk(HiveBoxes.progress, progressKeys);

      for (final entry in eventJsonMap.entries) {
        final eventJson = entry.value;
        if (eventJson != null && eventJson.isNotEmpty) {
          try {
            final eventData = jsonDecode(eventJson) as Map<String, dynamic>;
            final event = ProgressEvent.fromJson(eventData);
            events.add(event);
          } catch (e) {
            _logger.w(
                'Failed to parse event ${entry.key}',
                error: e);
            continue;
          }
        }
      }

      // Sort by timestamp (newest first)
      events.sort((a, b) => b.ts.compareTo(a.ts));

      return events;
    } catch (e, stackTrace) {
      _logger.e('Failed to load progress events',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets progress events for a specific program
  Future<List<ProgressEvent>> getEventsByProgram(String programId) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.where((event) => event.programId == programId).toList();
    } catch (e, stackTrace) {
      _logger.e(
          'Failed to load events for program $programId',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets progress events within a date range
  Future<List<ProgressEvent>> getEventsByDateRange(
      DateTime start, DateTime end) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents
          .where((event) => event.ts.isAfter(start) && event.ts.isBefore(end))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to load events for date range',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets the most recent progress events
  Future<List<ProgressEvent>> getRecentEvents({int limit = 50}) async {
    try {
      final allEvents = await getAllEvents();
      return allEvents.take(limit).toList();
    } catch (e, stackTrace) {
      _logger.e('LocalProgressSource: Failed to load recent events',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Provides a stream of all progress events
  Stream<List<ProgressEvent>> watchAllEvents() {
    // Emit current state immediately
    getAllEvents().then((events) {
      if (!_progressController.isClosed) {
        _progressController.add(events);
      }
    }).catchError((e) {
      _logger.e('LocalProgressSource: Error in initial stream emission',
          error: e);
    });

    return _progressController.stream;
  }

  /// Clears all progress events (use with caution!)
  Future<bool> clearAllEvents() async {
    try {
      _logger.w('LocalProgressSource: Clearing all progress events');

      final keys = await LocalKVStore.getKeys(HiveBoxes.progress);
      final progressKeys = keys
          .where(
              (key) => key.startsWith(_progressKeyPrefix) && key != _counterKey)
          .toList();

      bool allSuccess = true;
      for (final key in progressKeys) {
        final success = await LocalKVStore.delete(HiveBoxes.progress, key);
        if (!success) {
          allSuccess = false;
          _logger.w('LocalProgressSource: Failed to delete key: $key');
        }
      }

      // Reset counter
      await LocalKVStore.delete(HiveBoxes.progress, _counterKey);

      if (allSuccess) {
        _logger
            .w('LocalProgressSource: Successfully cleared all progress events');
        _notifyProgressChanged();
      }

      return allSuccess;
    } catch (e, stackTrace) {
      _logger.e('LocalProgressSource: Failed to clear progress events',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Deletes all progress events for a specific program
  Future<bool> deleteEventsByProgram(String programId) async {
    try {
      _logger.w('LocalProgressSource: Deleting events for program: $programId');

      final keys = await LocalKVStore.getKeys(HiveBoxes.progress);
      final progressKeys = keys
          .where(
              (key) => key.startsWith(_progressKeyPrefix) && key != _counterKey)
          .toList();

      bool allSuccess = true;
      int deletedCount = 0;

      for (final key in progressKeys) {
        final eventJson = await LocalKVStore.read(HiveBoxes.progress, key);
        if (eventJson != null && eventJson.isNotEmpty) {
          try {
            final eventData = jsonDecode(eventJson) as Map<String, dynamic>;
            final event = ProgressEvent.fromJson(eventData);

            // Delete if this event belongs to the specified program
            if (event.programId == programId) {
              final success =
                  await LocalKVStore.delete(HiveBoxes.progress, key);
              if (success) {
                deletedCount++;
              } else {
                allSuccess = false;
                _logger.w('LocalProgressSource: Failed to delete key: $key');
              }
            }
          } catch (e) {
            _logger.w(
                'LocalProgressSource: Failed to parse event $key - skipping',
                error: e);
          }
        }
      }

      if (allSuccess) {
        _logger.w(
            'LocalProgressSource: Successfully deleted $deletedCount events for program $programId');
        _notifyProgressChanged();
      }

      return allSuccess;
    } catch (e, stackTrace) {
      _logger.e(
          'LocalProgressSource: Failed to delete events for program $programId',
          error: e,
          stackTrace: stackTrace);
      return false;
    }
  }

  /// Gets the next counter value for unique key generation
  Future<int> _getNextCounter() async {
    try {
      final counterJson =
          await LocalKVStore.read(HiveBoxes.progress, _counterKey);
      int counter = 0;

      if (counterJson != null) {
        counter = int.tryParse(counterJson) ?? 0;
      }

      counter++;
      await LocalKVStore.write(
          HiveBoxes.progress, _counterKey, counter.toString());

      return counter;
    } catch (e) {
      _logger.w('LocalProgressSource: Failed to get counter, using timestamp',
          error: e);
      return DateTime.now().millisecondsSinceEpoch % 1000000;
    }
  }

  /// Notifies stream listeners of progress changes
  void _notifyProgressChanged() async {
    try {
      final events = await getAllEvents();
      if (!_progressController.isClosed) {
        _progressController.add(events);
      }
    } catch (e) {
      _logger.e('LocalProgressSource: Error notifying progress changes',
          error: e);
    }
  }

  /// Disposes the stream controller (call on app shutdown)
  static void dispose() {
    if (!_progressController.isClosed) {
      _progressController.close();
    }
  }
}
