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
String _$availableExtrasHash() => r'8109c166d2c8b223db97dda4632a6a4d2c69b289';

/// Available extras provider
///
/// Copied from [availableExtras].
@ProviderFor(availableExtras)
final availableExtrasProvider =
    AutoDisposeFutureProvider<List<ExtraItem>>.internal(
  availableExtras,
  name: r'availableExtrasProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableExtrasHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableExtrasRef = AutoDisposeFutureProviderRef<List<ExtraItem>>;
String _$expressWorkoutsHash() => r'c2b3860733773d4b60826e5fc72fcb9a98c21fd2';

/// Express workouts provider
///
/// Copied from [expressWorkouts].
@ProviderFor(expressWorkouts)
final expressWorkoutsProvider =
    AutoDisposeFutureProvider<List<ExtraItem>>.internal(
  expressWorkouts,
  name: r'expressWorkoutsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expressWorkoutsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpressWorkoutsRef = AutoDisposeFutureProviderRef<List<ExtraItem>>;
String _$bonusChallengesHash() => r'e2c1bd9d8c2cc1b42d26986f59d0d8427c026b8b';

/// Bonus challenges provider
///
/// Copied from [bonusChallenges].
@ProviderFor(bonusChallenges)
final bonusChallengesProvider =
    AutoDisposeFutureProvider<List<ExtraItem>>.internal(
  bonusChallenges,
  name: r'bonusChallengesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bonusChallengesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BonusChallengesRef = AutoDisposeFutureProviderRef<List<ExtraItem>>;
String _$mobilityRecoveryHash() => r'67aa8059dd77e1d56ba2557368ee70c3d9fde5dd';

/// Mobility & recovery provider
///
/// Copied from [mobilityRecovery].
@ProviderFor(mobilityRecovery)
final mobilityRecoveryProvider =
    AutoDisposeFutureProvider<List<ExtraItem>>.internal(
  mobilityRecovery,
  name: r'mobilityRecoveryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mobilityRecoveryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MobilityRecoveryRef = AutoDisposeFutureProviderRef<List<ExtraItem>>;
String _$performanceAnalyticsHash() =>
    r'5a3eeb1ea2eb38109d62a5c2e6fcfc97799d2ae4';

/// Performance analytics provider
///
/// Copied from [performanceAnalytics].
@ProviderFor(performanceAnalytics)
final performanceAnalyticsProvider =
    AutoDisposeFutureProvider<PerformanceAnalytics?>.internal(
  performanceAnalytics,
  name: r'performanceAnalyticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$performanceAnalyticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PerformanceAnalyticsRef
    = AutoDisposeFutureProviderRef<PerformanceAnalytics?>;
String _$categoryProgressHash() => r'2be8d69d54c16e3da3ccc59e0b44051e9703177f';

/// Current category progress provider
///
/// Copied from [categoryProgress].
@ProviderFor(categoryProgress)
final categoryProgressProvider =
    AutoDisposeFutureProvider<Map<ExerciseCategory, double>>.internal(
  categoryProgress,
  name: r'categoryProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryProgressRef
    = AutoDisposeFutureProviderRef<Map<ExerciseCategory, double>>;
String _$weeklyStatsHash() => r'4f2fb924e75036428599973ec68f82a52200eef5';

/// Weekly training stats provider
///
/// Copied from [weeklyStats].
@ProviderFor(weeklyStats)
final weeklyStatsProvider = AutoDisposeFutureProvider<WeeklyStats?>.internal(
  weeklyStats,
  name: r'weeklyStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$weeklyStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyStatsRef = AutoDisposeFutureProviderRef<WeeklyStats?>;
String _$streakDataHash() => r'310af29deb5412cf46da605a39c26130dd2293e4';

/// Streak data provider
///
/// Copied from [streakData].
@ProviderFor(streakData)
final streakDataProvider = AutoDisposeFutureProvider<StreakData?>.internal(
  streakData,
  name: r'streakDataProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$streakDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StreakDataRef = AutoDisposeFutureProviderRef<StreakData?>;
String _$personalBestsHash() => r'c4c79d644182e27fcb9ac8211035a59334fc5761';

/// Personal bests provider
///
/// Copied from [personalBests].
@ProviderFor(personalBests)
final personalBestsProvider =
    AutoDisposeFutureProvider<Map<String, PersonalBest>>.internal(
  personalBests,
  name: r'personalBestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$personalBestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PersonalBestsRef
    = AutoDisposeFutureProviderRef<Map<String, PersonalBest>>;
String _$intensityTrendsHash() => r'5fad025b6b0afb8efec52d10467947535b8c5e22';

/// Training intensity trends provider
///
/// Copied from [intensityTrends].
@ProviderFor(intensityTrends)
final intensityTrendsProvider =
    AutoDisposeFutureProvider<List<IntensityDataPoint>>.internal(
  intensityTrends,
  name: r'intensityTrendsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$intensityTrendsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IntensityTrendsRef
    = AutoDisposeFutureProviderRef<List<IntensityDataPoint>>;
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
    r'696205d1cfc800bbec7f1750cbeab450477ce88a';

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
    r'7fe5f242927371fc4910ef9f225cea08d7327496';

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
    r'41a463538cdfb53dad79eda81279855d80b12c72';

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
String _$startSessionActionHash() =>
    r'b933f2a6f4d05b478c97d07c2ba842100a96784e';

/// Start session action provider
///
/// Copied from [startSessionAction].
@ProviderFor(startSessionAction)
const startSessionActionProvider = StartSessionActionFamily();

/// Start session action provider
///
/// Copied from [startSessionAction].
class StartSessionActionFamily extends Family<AsyncValue<void>> {
  /// Start session action provider
  ///
  /// Copied from [startSessionAction].
  const StartSessionActionFamily();

  /// Start session action provider
  ///
  /// Copied from [startSessionAction].
  StartSessionActionProvider call(
    String programId,
    int week,
    int session,
  ) {
    return StartSessionActionProvider(
      programId,
      week,
      session,
    );
  }

  @override
  StartSessionActionProvider getProviderOverride(
    covariant StartSessionActionProvider provider,
  ) {
    return call(
      provider.programId,
      provider.week,
      provider.session,
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
  String? get name => r'startSessionActionProvider';
}

/// Start session action provider
///
/// Copied from [startSessionAction].
class StartSessionActionProvider extends AutoDisposeFutureProvider<void> {
  /// Start session action provider
  ///
  /// Copied from [startSessionAction].
  StartSessionActionProvider(
    String programId,
    int week,
    int session,
  ) : this._internal(
          (ref) => startSessionAction(
            ref as StartSessionActionRef,
            programId,
            week,
            session,
          ),
          from: startSessionActionProvider,
          name: r'startSessionActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$startSessionActionHash,
          dependencies: StartSessionActionFamily._dependencies,
          allTransitiveDependencies:
              StartSessionActionFamily._allTransitiveDependencies,
          programId: programId,
          week: week,
          session: session,
        );

  StartSessionActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
    required this.week,
    required this.session,
  }) : super.internal();

  final String programId;
  final int week;
  final int session;

  @override
  Override overrideWith(
    FutureOr<void> Function(StartSessionActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StartSessionActionProvider._internal(
        (ref) => create(ref as StartSessionActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        programId: programId,
        week: week,
        session: session,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _StartSessionActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StartSessionActionProvider &&
        other.programId == programId &&
        other.week == week &&
        other.session == session;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);
    hash = _SystemHash.combine(hash, week.hashCode);
    hash = _SystemHash.combine(hash, session.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StartSessionActionRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `programId` of this provider.
  String get programId;

  /// The parameter `week` of this provider.
  int get week;

  /// The parameter `session` of this provider.
  int get session;
}

class _StartSessionActionProviderElement
    extends AutoDisposeFutureProviderElement<void> with StartSessionActionRef {
  _StartSessionActionProviderElement(super.provider);

  @override
  String get programId => (origin as StartSessionActionProvider).programId;
  @override
  int get week => (origin as StartSessionActionProvider).week;
  @override
  int get session => (origin as StartSessionActionProvider).session;
}

String _$completeExtraActionHash() =>
    r'94d2105925bc6c42cfd8b59053eebe91e962e0f0';

/// Complete extra action provider
///
/// Copied from [completeExtraAction].
@ProviderFor(completeExtraAction)
const completeExtraActionProvider = CompleteExtraActionFamily();

/// Complete extra action provider
///
/// Copied from [completeExtraAction].
class CompleteExtraActionFamily extends Family<AsyncValue<void>> {
  /// Complete extra action provider
  ///
  /// Copied from [completeExtraAction].
  const CompleteExtraActionFamily();

  /// Complete extra action provider
  ///
  /// Copied from [completeExtraAction].
  CompleteExtraActionProvider call(
    String extraId,
    int xpReward,
  ) {
    return CompleteExtraActionProvider(
      extraId,
      xpReward,
    );
  }

  @override
  CompleteExtraActionProvider getProviderOverride(
    covariant CompleteExtraActionProvider provider,
  ) {
    return call(
      provider.extraId,
      provider.xpReward,
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
  String? get name => r'completeExtraActionProvider';
}

/// Complete extra action provider
///
/// Copied from [completeExtraAction].
class CompleteExtraActionProvider extends AutoDisposeFutureProvider<void> {
  /// Complete extra action provider
  ///
  /// Copied from [completeExtraAction].
  CompleteExtraActionProvider(
    String extraId,
    int xpReward,
  ) : this._internal(
          (ref) => completeExtraAction(
            ref as CompleteExtraActionRef,
            extraId,
            xpReward,
          ),
          from: completeExtraActionProvider,
          name: r'completeExtraActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$completeExtraActionHash,
          dependencies: CompleteExtraActionFamily._dependencies,
          allTransitiveDependencies:
              CompleteExtraActionFamily._allTransitiveDependencies,
          extraId: extraId,
          xpReward: xpReward,
        );

  CompleteExtraActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.extraId,
    required this.xpReward,
  }) : super.internal();

  final String extraId;
  final int xpReward;

  @override
  Override overrideWith(
    FutureOr<void> Function(CompleteExtraActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CompleteExtraActionProvider._internal(
        (ref) => create(ref as CompleteExtraActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        extraId: extraId,
        xpReward: xpReward,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _CompleteExtraActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompleteExtraActionProvider &&
        other.extraId == extraId &&
        other.xpReward == xpReward;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, extraId.hashCode);
    hash = _SystemHash.combine(hash, xpReward.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CompleteExtraActionRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `extraId` of this provider.
  String get extraId;

  /// The parameter `xpReward` of this provider.
  int get xpReward;
}

class _CompleteExtraActionProviderElement
    extends AutoDisposeFutureProviderElement<void> with CompleteExtraActionRef {
  _CompleteExtraActionProviderElement(super.provider);

  @override
  String get extraId => (origin as CompleteExtraActionProvider).extraId;
  @override
  int get xpReward => (origin as CompleteExtraActionProvider).xpReward;
}

String _$updateRoleActionHash() => r'5de21297127b6375e96a56021263f51c718cf403';

/// Update role action provider
///
/// Copied from [updateRoleAction].
@ProviderFor(updateRoleAction)
const updateRoleActionProvider = UpdateRoleActionFamily();

/// Update role action provider
///
/// Copied from [updateRoleAction].
class UpdateRoleActionFamily extends Family<AsyncValue<bool>> {
  /// Update role action provider
  ///
  /// Copied from [updateRoleAction].
  const UpdateRoleActionFamily();

  /// Update role action provider
  ///
  /// Copied from [updateRoleAction].
  UpdateRoleActionProvider call(
    UserRole role,
  ) {
    return UpdateRoleActionProvider(
      role,
    );
  }

  @override
  UpdateRoleActionProvider getProviderOverride(
    covariant UpdateRoleActionProvider provider,
  ) {
    return call(
      provider.role,
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
  String? get name => r'updateRoleActionProvider';
}

/// Update role action provider
///
/// Copied from [updateRoleAction].
class UpdateRoleActionProvider extends AutoDisposeFutureProvider<bool> {
  /// Update role action provider
  ///
  /// Copied from [updateRoleAction].
  UpdateRoleActionProvider(
    UserRole role,
  ) : this._internal(
          (ref) => updateRoleAction(
            ref as UpdateRoleActionRef,
            role,
          ),
          from: updateRoleActionProvider,
          name: r'updateRoleActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateRoleActionHash,
          dependencies: UpdateRoleActionFamily._dependencies,
          allTransitiveDependencies:
              UpdateRoleActionFamily._allTransitiveDependencies,
          role: role,
        );

  UpdateRoleActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
  }) : super.internal();

  final UserRole role;

  @override
  Override overrideWith(
    FutureOr<bool> Function(UpdateRoleActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateRoleActionProvider._internal(
        (ref) => create(ref as UpdateRoleActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _UpdateRoleActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateRoleActionProvider && other.role == role;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateRoleActionRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `role` of this provider.
  UserRole get role;
}

class _UpdateRoleActionProviderElement
    extends AutoDisposeFutureProviderElement<bool> with UpdateRoleActionRef {
  _UpdateRoleActionProviderElement(super.provider);

  @override
  UserRole get role => (origin as UpdateRoleActionProvider).role;
}

String _$updateUnitsActionHash() => r'c8b16d0807517a8440ca46c195fcf6d1e0e627b3';

/// Update units action provider
///
/// Copied from [updateUnitsAction].
@ProviderFor(updateUnitsAction)
const updateUnitsActionProvider = UpdateUnitsActionFamily();

/// Update units action provider
///
/// Copied from [updateUnitsAction].
class UpdateUnitsActionFamily extends Family<AsyncValue<bool>> {
  /// Update units action provider
  ///
  /// Copied from [updateUnitsAction].
  const UpdateUnitsActionFamily();

  /// Update units action provider
  ///
  /// Copied from [updateUnitsAction].
  UpdateUnitsActionProvider call(
    String units,
  ) {
    return UpdateUnitsActionProvider(
      units,
    );
  }

  @override
  UpdateUnitsActionProvider getProviderOverride(
    covariant UpdateUnitsActionProvider provider,
  ) {
    return call(
      provider.units,
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
  String? get name => r'updateUnitsActionProvider';
}

/// Update units action provider
///
/// Copied from [updateUnitsAction].
class UpdateUnitsActionProvider extends AutoDisposeFutureProvider<bool> {
  /// Update units action provider
  ///
  /// Copied from [updateUnitsAction].
  UpdateUnitsActionProvider(
    String units,
  ) : this._internal(
          (ref) => updateUnitsAction(
            ref as UpdateUnitsActionRef,
            units,
          ),
          from: updateUnitsActionProvider,
          name: r'updateUnitsActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateUnitsActionHash,
          dependencies: UpdateUnitsActionFamily._dependencies,
          allTransitiveDependencies:
              UpdateUnitsActionFamily._allTransitiveDependencies,
          units: units,
        );

  UpdateUnitsActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.units,
  }) : super.internal();

  final String units;

  @override
  Override overrideWith(
    FutureOr<bool> Function(UpdateUnitsActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateUnitsActionProvider._internal(
        (ref) => create(ref as UpdateUnitsActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        units: units,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _UpdateUnitsActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateUnitsActionProvider && other.units == units;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, units.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateUnitsActionRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `units` of this provider.
  String get units;
}

class _UpdateUnitsActionProviderElement
    extends AutoDisposeFutureProviderElement<bool> with UpdateUnitsActionRef {
  _UpdateUnitsActionProviderElement(super.provider);

  @override
  String get units => (origin as UpdateUnitsActionProvider).units;
}

String _$updateLanguageActionHash() =>
    r'54b19546e89c72beead6e26790c5cc3cea912782';

/// Update language action provider
///
/// Copied from [updateLanguageAction].
@ProviderFor(updateLanguageAction)
const updateLanguageActionProvider = UpdateLanguageActionFamily();

/// Update language action provider
///
/// Copied from [updateLanguageAction].
class UpdateLanguageActionFamily extends Family<AsyncValue<bool>> {
  /// Update language action provider
  ///
  /// Copied from [updateLanguageAction].
  const UpdateLanguageActionFamily();

  /// Update language action provider
  ///
  /// Copied from [updateLanguageAction].
  UpdateLanguageActionProvider call(
    String language,
  ) {
    return UpdateLanguageActionProvider(
      language,
    );
  }

  @override
  UpdateLanguageActionProvider getProviderOverride(
    covariant UpdateLanguageActionProvider provider,
  ) {
    return call(
      provider.language,
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
  String? get name => r'updateLanguageActionProvider';
}

/// Update language action provider
///
/// Copied from [updateLanguageAction].
class UpdateLanguageActionProvider extends AutoDisposeFutureProvider<bool> {
  /// Update language action provider
  ///
  /// Copied from [updateLanguageAction].
  UpdateLanguageActionProvider(
    String language,
  ) : this._internal(
          (ref) => updateLanguageAction(
            ref as UpdateLanguageActionRef,
            language,
          ),
          from: updateLanguageActionProvider,
          name: r'updateLanguageActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateLanguageActionHash,
          dependencies: UpdateLanguageActionFamily._dependencies,
          allTransitiveDependencies:
              UpdateLanguageActionFamily._allTransitiveDependencies,
          language: language,
        );

  UpdateLanguageActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.language,
  }) : super.internal();

  final String language;

  @override
  Override overrideWith(
    FutureOr<bool> Function(UpdateLanguageActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateLanguageActionProvider._internal(
        (ref) => create(ref as UpdateLanguageActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        language: language,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _UpdateLanguageActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateLanguageActionProvider && other.language == language;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, language.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateLanguageActionRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `language` of this provider.
  String get language;
}

class _UpdateLanguageActionProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with UpdateLanguageActionRef {
  _UpdateLanguageActionProviderElement(super.provider);

  @override
  String get language => (origin as UpdateLanguageActionProvider).language;
}

String _$updateThemeActionHash() => r'2c364e1036a81eea270a866c1a76ec2d83e9510e';

/// Update theme action provider
///
/// Copied from [updateThemeAction].
@ProviderFor(updateThemeAction)
const updateThemeActionProvider = UpdateThemeActionFamily();

/// Update theme action provider
///
/// Copied from [updateThemeAction].
class UpdateThemeActionFamily extends Family<AsyncValue<bool>> {
  /// Update theme action provider
  ///
  /// Copied from [updateThemeAction].
  const UpdateThemeActionFamily();

  /// Update theme action provider
  ///
  /// Copied from [updateThemeAction].
  UpdateThemeActionProvider call(
    String theme,
  ) {
    return UpdateThemeActionProvider(
      theme,
    );
  }

  @override
  UpdateThemeActionProvider getProviderOverride(
    covariant UpdateThemeActionProvider provider,
  ) {
    return call(
      provider.theme,
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
  String? get name => r'updateThemeActionProvider';
}

/// Update theme action provider
///
/// Copied from [updateThemeAction].
class UpdateThemeActionProvider extends AutoDisposeFutureProvider<bool> {
  /// Update theme action provider
  ///
  /// Copied from [updateThemeAction].
  UpdateThemeActionProvider(
    String theme,
  ) : this._internal(
          (ref) => updateThemeAction(
            ref as UpdateThemeActionRef,
            theme,
          ),
          from: updateThemeActionProvider,
          name: r'updateThemeActionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateThemeActionHash,
          dependencies: UpdateThemeActionFamily._dependencies,
          allTransitiveDependencies:
              UpdateThemeActionFamily._allTransitiveDependencies,
          theme: theme,
        );

  UpdateThemeActionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.theme,
  }) : super.internal();

  final String theme;

  @override
  Override overrideWith(
    FutureOr<bool> Function(UpdateThemeActionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateThemeActionProvider._internal(
        (ref) => create(ref as UpdateThemeActionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        theme: theme,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _UpdateThemeActionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateThemeActionProvider && other.theme == theme;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, theme.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UpdateThemeActionRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `theme` of this provider.
  String get theme;
}

class _UpdateThemeActionProviderElement
    extends AutoDisposeFutureProviderElement<bool> with UpdateThemeActionRef {
  _UpdateThemeActionProviderElement(super.provider);

  @override
  String get theme => (origin as UpdateThemeActionProvider).theme;
}

String _$exportLogsActionHash() => r'9123c78896399972a371660221b791d7738a4c14';

/// Export logs action provider
///
/// Copied from [exportLogsAction].
@ProviderFor(exportLogsAction)
final exportLogsActionProvider = AutoDisposeFutureProvider<String?>.internal(
  exportLogsAction,
  name: r'exportLogsActionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exportLogsActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExportLogsActionRef = AutoDisposeFutureProviderRef<String?>;
String _$deleteAccountActionHash() =>
    r'185908ef147eb2646a0bbe61668a03c07957e812';

/// Delete account action provider
///
/// Copied from [deleteAccountAction].
@ProviderFor(deleteAccountAction)
final deleteAccountActionProvider = AutoDisposeFutureProvider<bool>.internal(
  deleteAccountAction,
  name: r'deleteAccountActionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteAccountActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeleteAccountActionRef = AutoDisposeFutureProviderRef<bool>;
String _$initializePerformanceAnalyticsActionHash() =>
    r'be9bc07d7023181c0c24df57ae612c924831e16c';

/// Initialize performance analytics action provider
///
/// Copied from [initializePerformanceAnalyticsAction].
@ProviderFor(initializePerformanceAnalyticsAction)
final initializePerformanceAnalyticsActionProvider =
    AutoDisposeFutureProvider<void>.internal(
  initializePerformanceAnalyticsAction,
  name: r'initializePerformanceAnalyticsActionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initializePerformanceAnalyticsActionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitializePerformanceAnalyticsActionRef
    = AutoDisposeFutureProviderRef<void>;
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
