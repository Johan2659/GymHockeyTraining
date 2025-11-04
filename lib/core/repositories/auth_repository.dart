import '../models/models.dart';

/// Repository interface for managing user authentication
abstract class AuthRepository {
  /// Gets the currently logged-in user profile
  /// Returns null if no user is logged in
  Future<UserProfile?> getCurrentUser();

  /// Watches the current user for changes
  Stream<UserProfile?> watchCurrentUser();

  /// Checks if a user is currently logged in
  Future<bool> isLoggedIn();

  /// Logs in with an existing username
  /// Returns the user profile if successful, null if user doesn't exist
  Future<UserProfile?> login(String username);

  /// Creates a new user account with username
  /// Returns the created profile if successful, null if username exists
  Future<UserProfile?> signUp(String username);

  /// Logs out the current user
  Future<bool> logout();

  /// Gets all registered users (username: userId map)
  Future<Map<String, String>> getAllUsers();

  /// Checks if a username already exists
  Future<bool> usernameExists(String username);

  /// Updates the current user profile
  Future<bool> updateUserProfile(UserProfile profile);

  /// Deletes a user account (for testing/admin)
  Future<bool> deleteUser(String userId);
}
