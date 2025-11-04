// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userProfileStreamHash() => r'b99382a93e134b3cb4f5a67479d88297bd952547';

/// Provider for the current user profile from onboarding
///
/// Copied from [userProfileStream].
@ProviderFor(userProfileStream)
final userProfileStreamProvider =
    AutoDisposeStreamProvider<UserProfile?>.internal(
  userProfileStream,
  name: r'userProfileStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userProfileStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileStreamRef = AutoDisposeStreamProviderRef<UserProfile?>;
String _$hasCompletedOnboardingHash() =>
    r'e439bb2c3051cf9f6ee1267c44cf4d8f58ee1f9d';

/// Provider to check if onboarding is completed
///
/// Copied from [hasCompletedOnboarding].
@ProviderFor(hasCompletedOnboarding)
final hasCompletedOnboardingProvider = AutoDisposeFutureProvider<bool>.internal(
  hasCompletedOnboarding,
  name: r'hasCompletedOnboardingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasCompletedOnboardingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasCompletedOnboardingRef = AutoDisposeFutureProviderRef<bool>;
String _$currentUserProfileHash() =>
    r'5cc335e466ccc75d506682a7df1211a4ba7f5864';

/// Provider for getting the current user profile
///
/// Copied from [currentUserProfile].
@ProviderFor(currentUserProfile)
final currentUserProfileProvider =
    AutoDisposeFutureProvider<UserProfile?>.internal(
  currentUserProfile,
  name: r'currentUserProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserProfileRef = AutoDisposeFutureProviderRef<UserProfile?>;
String _$onboardingControllerHash() =>
    r'3c59ea468192f4050438b33fff00117fa2175551';

/// Controller for managing onboarding flow state
///
/// Copied from [OnboardingController].
@ProviderFor(OnboardingController)
final onboardingControllerProvider =
    AutoDisposeNotifierProvider<OnboardingController, OnboardingState>.internal(
  OnboardingController.new,
  name: r'onboardingControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnboardingController = AutoDisposeNotifier<OnboardingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
