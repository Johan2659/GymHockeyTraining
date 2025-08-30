import '../models/models.dart';

/// Repository interface for managing user profile and preferences
/// Provides SSOT for user settings and profile data
abstract class ProfileRepository {
  /// Gets the current user profile
  /// Returns null if no profile exists (first run)
  Future<Profile?> get();

  /// Saves the user profile
  /// Returns true if successful, false otherwise
  Future<bool> save(Profile profile);

  /// Watches the profile for changes
  /// Useful for reactive UI updates when profile changes
  Stream<Profile?> watch();

  /// Updates specific profile fields efficiently
  /// More efficient than loading, modifying, and saving entire profile
  Future<bool> updateRole(UserRole role);
  Future<bool> updateLanguage(String language);
  Future<bool> updateUnits(String units);
  Future<bool> updateTheme(String theme);

  /// Clears the user profile (use with caution!)
  /// Mainly for user logout or data reset
  Future<bool> clear();

  /// Checks if a profile exists
  /// Useful for onboarding flow decisions
  Future<bool> exists();
}
