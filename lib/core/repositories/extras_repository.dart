import '../models/models.dart';

/// Repository interface for managing extras (express workouts, bonus challenges, mobility)
abstract class ExtrasRepository {
  /// Gets all available extras
  Future<List<ExtraItem>> getAll();

  /// Gets extras filtered by type
  Future<List<ExtraItem>> getByType(ExtraType type);

  /// Gets a specific extra by ID
  Future<ExtraItem?> getById(String id);
}
