import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymhockeytraining/core/repositories/auth_repository.dart';
import 'package:gymhockeytraining/data/repositories_impl/auth_repository_impl.dart';
import 'package:gymhockeytraining/core/models/models.dart';

/// Test script to verify authentication functionality
/// Run with: flutter test test_authentication.dart
void main() {
  group('Authentication System Tests', () {
    late AuthRepository authRepo;

    setUp(() {
      // Initialize repository
      authRepo = AuthRepositoryImpl();
    });

    test('Sign up creates new user', () async {
      final username = 'TestUser${DateTime.now().millisecondsSinceEpoch}';
      
      // Sign up
      final profile = await authRepo.signUp(username);
      
      expect(profile, isNotNull);
      expect(profile?.username, equals(username));
      expect(profile?.onboardingCompleted, equals(false));
      expect(profile?.id, isNotEmpty);
      
      print('✅ Sign up successful for: $username');
    });

    test('Login with existing user works', () async {
      final username = 'LoginTest${DateTime.now().millisecondsSinceEpoch}';
      
      // Create user first
      await authRepo.signUp(username);
      
      // Logout
      await authRepo.logout();
      
      // Login
      final profile = await authRepo.login(username);
      
      expect(profile, isNotNull);
      expect(profile?.username, equals(username));
      
      print('✅ Login successful for: $username');
    });

    test('Duplicate username fails', () async {
      final username = 'DuplicateTest${DateTime.now().millisecondsSinceEpoch}';
      
      // Create first user
      final firstProfile = await authRepo.signUp(username);
      expect(firstProfile, isNotNull);
      
      // Try to create duplicate
      final duplicateProfile = await authRepo.signUp(username);
      expect(duplicateProfile, isNull);
      
      print('✅ Duplicate username rejected correctly');
    });

    test('Login with non-existent user fails', () async {
      final username = 'NonExistent${DateTime.now().millisecondsSinceEpoch}';
      
      // Try to login without signing up
      final profile = await authRepo.login(username);
      
      expect(profile, isNull);
      
      print('✅ Non-existent user login rejected correctly');
    });

    test('User session persists', () async {
      final username = 'SessionTest${DateTime.now().millisecondsSinceEpoch}';
      
      // Sign up
      await authRepo.signUp(username);
      
      // Check if logged in
      final isLoggedIn = await authRepo.isLoggedIn();
      expect(isLoggedIn, isTrue);
      
      // Get current user
      final currentUser = await authRepo.getCurrentUser();
      expect(currentUser, isNotNull);
      expect(currentUser?.username, equals(username));
      
      print('✅ User session persisted correctly');
    });

    test('Logout clears session', () async {
      final username = 'LogoutTest${DateTime.now().millisecondsSinceEpoch}';
      
      // Sign up
      await authRepo.signUp(username);
      
      // Logout
      final success = await authRepo.logout();
      expect(success, isTrue);
      
      // Check if logged out
      final isLoggedIn = await authRepo.isLoggedIn();
      expect(isLoggedIn, isFalse);
      
      final currentUser = await authRepo.getCurrentUser();
      expect(currentUser, isNull);
      
      print('✅ Logout cleared session correctly');
    });

    test('Update user profile works', () async {
      final username = 'UpdateTest${DateTime.now().millisecondsSinceEpoch}';
      
      // Sign up
      final profile = await authRepo.signUp(username);
      expect(profile, isNotNull);
      
      // Update profile
      final updatedProfile = profile!.copyWith(
        role: PlayerRole.goalie,
        goal: TrainingGoal.endurance,
        onboardingCompleted: true,
      );
      
      final success = await authRepo.updateUserProfile(updatedProfile);
      expect(success, isTrue);
      
      // Verify update
      final currentUser = await authRepo.getCurrentUser();
      expect(currentUser?.role, equals(PlayerRole.goalie));
      expect(currentUser?.goal, equals(TrainingGoal.endurance));
      expect(currentUser?.onboardingCompleted, equals(true));
      
      print('✅ Profile update successful');
    });

    test('Username validation works', () async {
      final existingUsername = 'ExistingUser${DateTime.now().millisecondsSinceEpoch}';
      
      // Create user
      await authRepo.signUp(existingUsername);
      
      // Check if exists
      final exists = await authRepo.usernameExists(existingUsername);
      expect(exists, isTrue);
      
      // Check non-existent username
      final notExists = await authRepo.usernameExists('NonExistentUser123456');
      expect(notExists, isFalse);
      
      print('✅ Username validation working correctly');
    });
  });

  group('Integration Tests', () {
    testWidgets('Complete authentication flow', (WidgetTester tester) async {
      // This would require full app initialization
      // For now, just a placeholder
      print('ℹ️  Integration tests require full app setup');
    });
  });

  print('\n🎉 All authentication tests completed!\n');
}
