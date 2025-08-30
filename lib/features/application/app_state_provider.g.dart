// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$progressEventsHash() => r'4122494ed95db842a66d182e0852d5dbbb2d1633';

/// Comprehensive app state provider that serves as the Single Source of Truth (SSOT)
/// Aggregates all repositories and computes derived values
/// Stream of all progress events
///
/// Copied from [progressEvents].
@ProviderFor(progressEvents)
final progressEventsProvider =
    AutoDisposeStreamProvider<List<ProgressEvent>>.internal(
  progressEvents,
  name: r'progressEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProgressEventsRef = AutoDisposeStreamProviderRef<List<ProgressEvent>>;
String _$programStateHash() => r'9cb98cfded1fec976cf5113d39f6f180994e3a73';

/// Stream of current program state
///
/// Copied from [programState].
@ProviderFor(programState)
final programStateProvider = AutoDisposeStreamProvider<ProgramState?>.internal(
  programState,
  name: r'programStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$programStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProgramStateRef = AutoDisposeStreamProviderRef<ProgramState?>;
String _$userProfileHash() => r'2a4861be11a22540ba996dbe9afbf0ff3e33e753';

/// Stream of user profile
///
/// Copied from [userProfile].
@ProviderFor(userProfile)
final userProfileProvider = AutoDisposeStreamProvider<Profile?>.internal(
  userProfile,
  name: r'userProfileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserProfileRef = AutoDisposeStreamProviderRef<Profile?>;
String _$availableProgramsHash() => r'b67952aac14e6a688eeaf6c32a7ab49e07b7922b';

/// Available programs provider
///
/// Copied from [availablePrograms].
@ProviderFor(availablePrograms)
final availableProgramsProvider =
    AutoDisposeFutureProvider<List<Program>>.internal(
  availablePrograms,
  name: r'availableProgramsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableProgramsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableProgramsRef = AutoDisposeFutureProviderRef<List<Program>>;
String _$activeProgramHash() => r'39c2c2d39eba686edf957c9169db24848c11b1ab';

/// Current active program provider
///
/// Copied from [activeProgram].
@ProviderFor(activeProgram)
final activeProgramProvider = AutoDisposeFutureProvider<Program?>.internal(
  activeProgram,
  name: r'activeProgramProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeProgramHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveProgramRef = AutoDisposeFutureProviderRef<Program?>;
String _$currentXPHash() => r'cd028186600f95569e014780f6bdcb7563035b28';

/// Current user XP
///
/// Copied from [currentXP].
@ProviderFor(currentXP)
final currentXPProvider = AutoDisposeFutureProvider<int>.internal(
  currentXP,
  name: r'currentXPProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentXPHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentXPRef = AutoDisposeFutureProviderRef<int>;
String _$todayXPHash() => r'5a208fba323da64ecaae747e453a6cdecaba323d';

/// XP gained today
///
/// Copied from [todayXP].
@ProviderFor(todayXP)
final todayXPProvider = AutoDisposeFutureProvider<int>.internal(
  todayXP,
  name: r'todayXPProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayXPHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayXPRef = AutoDisposeFutureProviderRef<int>;
String _$currentStreakHash() => r'30a28b504e458a604517a126333af7384bfd9cfc';

/// Current streak
///
/// Copied from [currentStreak].
@ProviderFor(currentStreak)
final currentStreakProvider = AutoDisposeFutureProvider<int>.internal(
  currentStreak,
  name: r'currentStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentStreakRef = AutoDisposeFutureProviderRef<int>;
String _$xpMultiplierHash() => r'68e78bd42ae9a31600b3fd5d437f4a465f6418de';

/// XP multiplier based on streak
///
/// Copied from [xpMultiplier].
@ProviderFor(xpMultiplier)
final xpMultiplierProvider = AutoDisposeProvider<double>.internal(
  xpMultiplier,
  name: r'xpMultiplierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$xpMultiplierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef XpMultiplierRef = AutoDisposeProviderRef<double>;
String _$percentCycleHash() => r'd5b997f7551e9f089a90c1029c7cf4ec50fdf86a';

/// Current program completion percentage (pure async)
///
/// Copied from [percentCycle].
@ProviderFor(percentCycle)
final percentCycleProvider = AutoDisposeFutureProvider<double>.internal(
  percentCycle,
  name: r'percentCycleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$percentCycleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PercentCycleRef = AutoDisposeFutureProviderRef<double>;
String _$nextSessionRefHash() => r'660f55a90078d4eb94460ec7ad96ea25fa26cc0f';

/// Next session reference
///
/// Copied from [nextSessionRef].
@ProviderFor(nextSessionRef)
final nextSessionRefProvider = AutoDisposeFutureProvider<Session?>.internal(
  nextSessionRef,
  name: r'nextSessionRefProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextSessionRefHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextSessionRefRef = AutoDisposeFutureProviderRef<Session?>;
String _$startProgramActionHash() =>
    r'75417f5b8f3901d9fc07bda60ba87d602fa26a04';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Start program action provider
///
/// Copied from [startProgramAction].
@ProviderFor(startProgramAction)
const startProgramActionProvider = StartProgramActionFamily();

/// Start program action provider
///
/// Copied from [startProgramAction].
class StartProgramActionFamily extends Family<AsyncValue<void>> {
  /// Start program action provider
  ///
  /// Copied from [startProgramAction].
  const StartProgramActionFamily();

  /// Start program action provider
  ///
  /// Copied from [startProgramAction].
  StartProgramActionProvider call(
    String programId,
  ) {
    return StartProgramActionProvider(
      programId,
    );
  }

  @override
  StartProgramActionProvider getProviderOverride(
    covariant StartProgramActionProvider provider,
  ) {
    return call(
      provider.programId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'startProgramActionProvider';
}

/// Start program action provider
///
/// Copied from [startProgramAction].
class StartProgramActionProvider extends AutoDisposeFutureProvider<void> {
  /// Start program action provider
  ///
  /// Copied from [startProgramAction].
  StartProgramActionProvider(
    String programId,
  ) : this._internal(
          (ref) => startProgramAction(
            ref as StartProgramActionRef,
            programId,
          ),
          from: startProgramActionProvider,
          name: r'startProgramActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$startProgramActionHash,
          dependencies: StartProgramActionFamily._dependencies,
          allTransitiveDependencies:
              StartProgramActionFamily._allTransitiveDependencies,
          programId: programId,
        );

  StartProgramActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
  }) : super.internal();

  final String programId;

  @override
  Override overrideWith(
    FutureOr<void> Function(StartProgramActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StartProgramActionProvider._internal(
        (ref) => create(ref as StartProgramActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        programId: programId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _StartProgramActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StartProgramActionProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StartProgramActionRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _StartProgramActionProviderElement
    extends AutoDisposeFutureProviderElement<void> with StartProgramActionRef {
  _StartProgramActionProviderElement(super.provider);

  @override
  String get programId => (origin as StartProgramActionProvider).programId;
}

String _$markExerciseDoneActionHash() =>
    r'7ac0f498557fca19600ca65e1eacfd88beee1fe5';

/// Mark exercise done action provider
///
/// Copied from [markExerciseDoneAction].
@ProviderFor(markExerciseDoneAction)
const markExerciseDoneActionProvider = MarkExerciseDoneActionFamily();

/// Mark exercise done action provider
///
/// Copied from [markExerciseDoneAction].
class MarkExerciseDoneActionFamily extends Family<AsyncValue<void>> {
  /// Mark exercise done action provider
  ///
  /// Copied from [markExerciseDoneAction].
  const MarkExerciseDoneActionFamily();

  /// Mark exercise done action provider
  ///
  /// Copied from [markExerciseDoneAction].
  MarkExerciseDoneActionProvider call(
    String exerciseId,
  ) {
    return MarkExerciseDoneActionProvider(
      exerciseId,
    );
  }

  @override
  MarkExerciseDoneActionProvider getProviderOverride(
    covariant MarkExerciseDoneActionProvider provider,
  ) {
    return call(
      provider.exerciseId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'markExerciseDoneActionProvider';
}

/// Mark exercise done action provider
///
/// Copied from [markExerciseDoneAction].
class MarkExerciseDoneActionProvider extends AutoDisposeFutureProvider<void> {
  /// Mark exercise done action provider
  ///
  /// Copied from [markExerciseDoneAction].
  MarkExerciseDoneActionProvider(
    String exerciseId,
  ) : this._internal(
          (ref) => markExerciseDoneAction(
            ref as MarkExerciseDoneActionRef,
            exerciseId,
          ),
          from: markExerciseDoneActionProvider,
          name: r'markExerciseDoneActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$markExerciseDoneActionHash,
          dependencies: MarkExerciseDoneActionFamily._dependencies,
          allTransitiveDependencies:
              MarkExerciseDoneActionFamily._allTransitiveDependencies,
          exerciseId: exerciseId,
        );

  MarkExerciseDoneActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.exerciseId,
  }) : super.internal();

  final String exerciseId;

  @override
  Override overrideWith(
    FutureOr<void> Function(MarkExerciseDoneActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarkExerciseDoneActionProvider._internal(
        (ref) => create(ref as MarkExerciseDoneActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        exerciseId: exerciseId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _MarkExerciseDoneActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkExerciseDoneActionProvider &&
        other.exerciseId == exerciseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, exerciseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarkExerciseDoneActionRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `exerciseId` of this provider.
  String get exerciseId;
}

class _MarkExerciseDoneActionProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with MarkExerciseDoneActionRef {
  _MarkExerciseDoneActionProviderElement(super.provider);

  @override
  String get exerciseId =>
      (origin as MarkExerciseDoneActionProvider).exerciseId;
}

String _$completeSessionActionHash() =>
    r'a2499d286a6397250649b982eca17579dfec07c8';

/// Complete session action provider
///
/// Copied from [completeSessionAction].
@ProviderFor(completeSessionAction)
final completeSessionActionProvider = AutoDisposeFutureProvider<void>.internal(
  completeSessionAction,
  name: r'completeSessionActionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completeSessionActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompleteSessionActionRef = AutoDisposeFutureProviderRef<void>;
String _$pauseProgramActionHash() =>
    r'cc53bed956d0a73aa7d9e7264c651979d1495b1b';

/// Pause program action provider
///
/// Copied from [pauseProgramAction].
@ProviderFor(pauseProgramAction)
final pauseProgramActionProvider = AutoDisposeFutureProvider<void>.internal(
  pauseProgramAction,
  name: r'pauseProgramActionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pauseProgramActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PauseProgramActionRef = AutoDisposeFutureProviderRef<void>;
String _$resumeProgramActionHash() =>
    r'c3ba39f13ab79c5a8396cfc774b4e3fde1cb021d';

/// Resume program action provider
///
/// Copied from [resumeProgramAction].
@ProviderFor(resumeProgramAction)
final resumeProgramActionProvider = AutoDisposeFutureProvider<void>.internal(
  resumeProgramAction,
  name: r'resumeProgramActionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resumeProgramActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ResumeProgramActionRef = AutoDisposeFutureProviderRef<void>;
String _$completeBonusChallengeActionHash() =>
    r'55ceeb21b92843629d60c81f7fb2f77f631c012b';

/// Complete bonus challenge action provider
///
/// Copied from [completeBonusChallengeAction].
@ProviderFor(completeBonusChallengeAction)
final completeBonusChallengeActionProvider =
    AutoDisposeFutureProvider<void>.internal(
  completeBonusChallengeAction,
  name: r'completeBonusChallengeActionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completeBonusChallengeActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompleteBonusChallengeActionRef = AutoDisposeFutureProviderRef<void>;
String _$appStateHash() => r'1cf6dac6c5d3fba4ff445cfbaad637743e5725a1';

/// Main app state provider that aggregates all state and provides action methods
///
/// Copied from [AppState].
@ProviderFor(AppState)
final appStateProvider =
    AutoDisposeAsyncNotifierProvider<AppState, AppStateData>.internal(
  AppState.new,
  name: r'appStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppState = AutoDisposeAsyncNotifier<AppStateData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
