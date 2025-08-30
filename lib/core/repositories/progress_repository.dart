import '../models/models.dart';

/// Repository interface for managing progress events and journaling
/// Provides SSOT for all progress tracking and user activity
abstract class ProgressRepository {
  /// Appends a new progress event to the journal
  /// Returns true if successful, false otherwise
  Future<bool> appendEvent(ProgressEvent event);

  /// Watches all progress events as a stream
  /// Updates when new events are added
  Stream<List<ProgressEvent>> watchAll();

  /// Gets all progress events for a specific program
  /// Useful for program-specific progress tracking
  Future<List<ProgressEvent>> getByProgram(String programId);

  /// Gets progress events within a date range
  /// Useful for weekly/monthly progress reports
  Future<List<ProgressEvent>> getByDateRange(DateTime start, DateTime end);

  /// Gets the most recent progress events
  /// Useful for activity feeds and recent progress display
  Future<List<ProgressEvent>> getRecent({int limit = 50});

  /// Clears all progress events (use with caution!)
  /// Mainly for testing or user data reset
  Future<bool> clearAll();
}
