import '../models/models.dart';

/// Repository interface for managing training programs
/// Provides access to static program definitions
abstract class ProgramRepository {
  /// Gets a program by its unique identifier
  /// Returns null if program is not found
  Future<Program?> getById(String id);

  /// Lists all programs available for a specific user role
  /// Returns empty list if no programs found for the role
  Future<List<Program>> listByRole(UserRole role);

  /// Gets all available programs regardless of role
  /// Useful for admin views or program discovery
  Future<List<Program>> getAll();
}
