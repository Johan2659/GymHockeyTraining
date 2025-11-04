/// Test script to verify the onboarding implementation
/// 
/// Run this with: dart run test_onboarding.dart
///
/// This script demonstrates how to:
/// 1. Check if onboarding is completed
/// 2. Clear onboarding state (to test the flow again)
/// 3. Read the saved user profile

import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'lib/core/storage/hive_boxes.dart';
import 'lib/core/storage/secure_key_service.dart';
import 'lib/data/repositories_impl/onboarding_repository_impl.dart';
import 'lib/core/models/models.dart';

void main() async {
  print('🏒 Hockey Gym - Onboarding Test Script');
  print('=' * 50);
  
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  print('📂 Initialized Hive at: ${appDocumentDir.path}');
  
  // Get encryption key
  final encryptionKey = await SecureKeyService.getOrCreateEncryptionKey();
  final cipher = HiveAesCipher(encryptionKey);
  print('🔐 Encryption ready');
  
  // Open the profile box
  await Hive.openBox(
    HiveBoxes.profile,
    encryptionCipher: cipher,
  );
  print('✅ Opened profile box\n');
  
  // Create repository instance
  final repo = OnboardingRepositoryImpl();
  
  // Check if onboarding is completed
  final hasCompleted = await repo.hasCompletedOnboarding();
  print('Has completed onboarding: $hasCompleted');
  
  if (hasCompleted) {
    // Read and display the user profile
    final profile = await repo.getUserProfile();
    if (profile != null) {
      print('\n👤 User Profile:');
      print('   Role: ${profile.role.name}');
      print('   Goal: ${profile.goal.name}');
      print('   Completed: ${profile.onboardingCompleted}');
      print('   Created: ${profile.createdAt}');
    }
    
    print('\n💡 To test onboarding again, uncomment the clearUserProfile() call below');
    print('   and run this script again.');
    
    // Uncomment this line to clear the profile and test onboarding again:
    // await repo.clearUserProfile();
    // print('\n✅ User profile cleared. Restart the app to see onboarding.');
  } else {
    print('\n📱 Onboarding not completed yet.');
    print('   Launch the app to see the onboarding flow!');
  }
  
  print('\n' + '=' * 50);
  print('Script complete. You can now exit.');
  
  // Close Hive
  await Hive.close();
  exit(0);
}
