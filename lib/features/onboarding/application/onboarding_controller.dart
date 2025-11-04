import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/di.dart';
import '../../../core/models/models.dart';
import '../../../core/services/logger_service.dart';

part 'onboarding_controller.g.dart';

/// Provider for the current user profile from onboarding
@riverpod
Stream<UserProfile?> userProfileStream(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.watchUserProfile();
}

/// Provider to check if onboarding is completed
@riverpod
Future<bool> hasCompletedOnboarding(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.hasCompletedOnboarding();
}

/// Provider for getting the current user profile
@riverpod
Future<UserProfile?> currentUserProfile(Ref ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.getUserProfile();
}

/// Onboarding state for in-progress onboarding flow
class OnboardingState {
  final PlayerRole? selectedRole;
  final TrainingGoal? selectedGoal;

  const OnboardingState({
    this.selectedRole,
    this.selectedGoal,
  });

  OnboardingState copyWith({
    PlayerRole? selectedRole,
    TrainingGoal? selectedGoal,
  }) {
    return OnboardingState(
      selectedRole: selectedRole ?? this.selectedRole,
      selectedGoal: selectedGoal ?? this.selectedGoal,
    );
  }
}

/// Controller for managing onboarding flow state
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  /// Sets the selected player role
  void setRole(PlayerRole role) {
    state = state.copyWith(selectedRole: role);
  }

  /// Sets the selected training goal
  void setGoal(TrainingGoal goal) {
    state = state.copyWith(selectedGoal: goal);
  }

  /// Completes the onboarding and saves the user profile
  Future<bool> completeOnboarding() async {
    if (state.selectedRole == null || state.selectedGoal == null) {
      LoggerService.instance.error(
        'Cannot complete onboarding: missing role or goal',
        source: 'OnboardingController',
      );
      return false;
    }

    final profile = UserProfile(
      role: state.selectedRole!,
      goal: state.selectedGoal!,
      onboardingCompleted: true,
      createdAt: DateTime.now(),
    );

    final repository = ref.read(onboardingRepositoryProvider);
    final success = await repository.saveUserProfile(profile);

    if (success) {
      LoggerService.instance.info(
        'Onboarding completed successfully',
        source: 'OnboardingController',
      );
      // Invalidate the onboarding status provider to refresh
      ref.invalidate(hasCompletedOnboardingProvider);
      ref.invalidate(currentUserProfileProvider);
    } else {
      LoggerService.instance.error(
        'Failed to save user profile',
        source: 'OnboardingController',
      );
    }

    return success;
  }

  /// Resets the onboarding state (for testing)
  void reset() {
    state = const OnboardingState();
  }
}
