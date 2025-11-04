// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentAuthUserHash() => r'7171daf0b76eef4186b1a24fb6c8c5daaf5e03c6';

/// Provider for the current authenticated user
///
/// Copied from [currentAuthUser].
@ProviderFor(currentAuthUser)
final currentAuthUserProvider =
    AutoDisposeStreamProvider<UserProfile?>.internal(
  currentAuthUser,
  name: r'currentAuthUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAuthUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentAuthUserRef = AutoDisposeStreamProviderRef<UserProfile?>;
String _$isUserLoggedInHash() => r'67f315a6bd554e1253f2f63a1ac569349a89922c';

/// Provider to check if a user is logged in
///
/// Copied from [isUserLoggedIn].
@ProviderFor(isUserLoggedIn)
final isUserLoggedInProvider = AutoDisposeFutureProvider<bool>.internal(
  isUserLoggedIn,
  name: r'isUserLoggedInProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isUserLoggedInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsUserLoggedInRef = AutoDisposeFutureProviderRef<bool>;
String _$currentUserProfileHash() =>
    r'32c1e4a7af6d54bed65a2e4eb5780babb986d4fb';

/// Provider for getting current user synchronously from async provider
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
String _$authControllerHash() => r'2085571b90b697d0b1cf05c8779a378ab9abf9d1';

/// Authentication state controller
///
/// Copied from [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
