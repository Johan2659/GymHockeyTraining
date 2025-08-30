import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../../core/models/models.dart';
import '../../core/storage/hive_boxes.dart';
import '../../core/storage/local_kv_store.dart';

/// Local data source for progress events using Hive storage
/// Provides append-only journaling with streaming capabilities
class LocalProgressSource {
  static final _logger = Logger();
  static const String _progressKeyPrefix = 'progress_';
  static const String _counterKey = 'progress_counter';
  
  // Stream controller for watching progress changes
  static final _progressController = StreamController<List<ProgressEvent>>.broadcast();

  /// Appends a new progress event to storage
  Future<bool> appendEvent(ProgressEvent event) async {
    try {
      _logger.d('LocalProgressSource: Appending progress event: ${event.type}');
      
      // Generate unique key using timestamp and counter
      final counter = await _getNextCounter();
      final key = '$_progressKeyPrefix${event.ts.millisecondsSinceEpoch}_$counter';
      
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
      _logger.d('LocalProgressSource: Loading all progress events');
      
      final keys = await LocalKVStore.getKeys(HiveBoxes.progress);
      final progressKeys = keys
          .where((key) => key.startsWith(_progressKeyPrefix) && key != _counterKey)
          .toList();
      
      final events = <ProgressEvent>[];
      
      for (final key in progressKeys) {
        final eventJson = await LocalKVStore.read(HiveBoxes.progress, key);
        if (eventJson != null && eventJson.isNotEmpty) {
          try {
            final eventData = jsonDecode(eventJson) as Map<String, dynamic>;
            final event = ProgressEvent.fromJson(eventData);
            events.add(event);
          } catch (e) {
            _logger.w('LocalProgressSource: Failed to parse event $key - skipping', error: e);
            // Continue processing other events instead of failing
            continue;
          }
        }
      }
      
      // Sort by timestamp (newest first)
      events.sort((a, b) => b.ts.compareTo(a.ts));
      
      _logger.d('LocalProgressSource: Loaded ${events.length} progress events');
      return events;
      
    } catch (e, stackTrace) {
      _logger.e('LocalProgressSource: Failed to load progress events', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets progress events for a specific program
  Future<List<ProgressEvent>> getEventsByProgram(String programId) async {
    try {
      _logger.d('LocalProgressSource: Loading events for program: $programId');
      
      final allEvents = await getAllEvents();
      final programEvents = allEvents
          .where((event) => event.programId == programId)
          .toList();
      
      _logger.d('LocalProgressSource: Found ${programEvents.length} events for program $programId');
      return programEvents;
      
    } catch (e, stackTrace) {
      _logger.e('LocalProgressSource: Failed to load events for program $programId', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets progress events within a date range
  Future<List<ProgressEvent>> getEventsByDateRange(DateTime start, DateTime end) async {
    try {
      _logger.d('LocalProgressSource: Loading events from $start to $end');
      
      final allEvents = await getAllEvents();
      final rangeEvents = allEvents
          .where((event) => 
              event.ts.isAfter(start) && event.ts.isBefore(end))
          .toList();
      
      _logger.d('LocalProgressSource: Found ${rangeEvents.length} events in date range');
      return rangeEvents;
      
    } catch (e, stackTrace) {
      _logger.e('LocalProgressSource: Failed to load events for date range', 
                error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets the most recent progress events
  Future<List<ProgressEvent>> getRecentEvents({int limit = 50}) async {
    try {
      _logger.d('LocalProgressSource: Loading $limit recent events');
      
      final allEvents = await getAllEvents();
      final recentEvents = allEvents.take(limit).toList();
      
      _logger.d('LocalProgressSource: Loaded ${recentEvents.length} recent events');
      return recentEvents;
      
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
      _logger.e('LocalProgressSource: Error in initial stream emission', error: e);
    });
    
    return _progressController.stream;
  }

  /// Clears all progress events (use with caution!)
  Future<bool> clearAllEvents() async {
    try {
      _logger.w('LocalProgressSource: Clearing all progress events');
      
      final keys = await LocalKVStore.getKeys(HiveBoxes.progress);
      final progressKeys = keys
          .where((key) => key.startsWith(_progressKeyPrefix) && key != _counterKey)
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
        _logger.w('LocalProgressSource: Successfully cleared all progress events');
        _notifyProgressChanged();
      }
      
      return allSuccess;
      
    } catch (e, stackTrace) {
      _logger.e('LocalProgressSource: Failed to clear progress events', 
                error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Gets the next counter value for unique key generation
  Future<int> _getNextCounter() async {
    try {
      final counterJson = await LocalKVStore.read(HiveBoxes.progress, _counterKey);
      int counter = 0;
      
      if (counterJson != null) {
        counter = int.tryParse(counterJson) ?? 0;
      }
      
      counter++;
      await LocalKVStore.write(HiveBoxes.progress, _counterKey, counter.toString());
      
      return counter;
      
    } catch (e) {
      _logger.w('LocalProgressSource: Failed to get counter, using timestamp', error: e);
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
      _logger.e('LocalProgressSource: Error notifying progress changes', error: e);
    }
  }

  /// Disposes the stream controller (call on app shutdown)
  static void dispose() {
    if (!_progressController.isClosed) {
      _progressController.close();
    }
  }
}
