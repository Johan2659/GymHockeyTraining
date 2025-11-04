import 'package:logger/logger.dart';

import '../../core/models/models.dart';
import 'extras_database.dart';

/// Local data source for extras definitions sourced from the extras database
class LocalExtrasSource {
  static final _logger = Logger();

  /// Gets all available extras
  Future<List<ExtraItem>> getAllExtras() async {
    try {
      _logger.d('LocalExtrasSource: Loading all extras from database');

      final extras = await ExtrasDatabase.getAllExtras();

      _logger.i('LocalExtrasSource: Loaded ${extras.length} extras');
      return extras;
    } catch (e, stackTrace) {
      _logger.e('LocalExtrasSource: Failed to load extras',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets extras filtered by type
  Future<List<ExtraItem>> getExtrasByType(ExtraType type) async {
    try {
      _logger.d('LocalExtrasSource: Loading extras for type: ${type.name}');

      final extras = await ExtrasDatabase.getExtrasByType(type);

      _logger.d(
          'LocalExtrasSource: Found ${extras.length} extras for type ${type.name}');
      return extras;
    } catch (e, stackTrace) {
      _logger.e(
          'LocalExtrasSource: Failed to load extras for type ${type.name}',
          error: e,
          stackTrace: stackTrace);
      return [];
    }
  }

  /// Gets a specific extra by ID
  Future<ExtraItem?> getExtraById(String id) async {
    try {
      _logger.d('LocalExtrasSource: Loading extra with ID: $id');

      final extra = await ExtrasDatabase.getExtraById(id);

      if (extra == null) {
        _logger.w('LocalExtrasSource: Extra not found with id: $id');
      }

      return extra;
    } catch (e, stackTrace) {
      _logger.e('LocalExtrasSource: Failed to load extra $id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }
}
