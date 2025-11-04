import '../models/models.dart';

/// Repository interface for managing onboarding and user profile state
abstract class OnboardingRepository {
  /// Gets the current user profile
  /// Returns null if onboarding hasn't been completed
  Future<UserProfile?> getUserProfile();

  /// Saves the user profile after onboarding
  /// Returns true if successful, false otherwise
  Future<bool> saveUserProfile(UserProfile profile);

  /// Checks if the user has completed onboarding
  Future<bool> hasCompletedOnboarding();

  /// Watches the user profile for changes
  /// Useful for reactive UI updates
  Stream<UserProfile?> watchUserProfile();

  /// Clears the user profile (for testing or reset)
  Future<bool> clearUserProfile();
}
