// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_player_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionHash() => r'1ab9ed74abb7a68b4889b2afe86115a93d1e4cb8';

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

/// See also [_session].
@ProviderFor(_session)
const _sessionProvider = _SessionFamily();

/// See also [_session].
class _SessionFamily extends Family<AsyncValue<Session>> {
  /// See also [_session].
  const _SessionFamily();

  /// See also [_session].
  _SessionProvider call(
    String week,
    String session,
  ) {
    return _SessionProvider(
      week,
      session,
    );
  }

  @override
  _SessionProvider getProviderOverride(
    covariant _SessionProvider provider,
  ) {
    return call(
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
  String? get name => r'_sessionProvider';
}

/// See also [_session].
class _SessionProvider extends AutoDisposeFutureProvider<Session> {
  /// See also [_session].
  _SessionProvider(
    String week,
    String session,
  ) : this._internal(
          (ref) => _session(
            ref as _SessionRef,
            week,
            session,
          ),
          from: _sessionProvider,
          name: r'_sessionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$sessionHash,
          dependencies: _SessionFamily._dependencies,
          allTransitiveDependencies: _SessionFamily._allTransitiveDependencies,
          week: week,
          session: session,
        );

  _SessionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.week,
    required this.session,
  }) : super.internal();

  final String week;
  final String session;

  @override
  Override overrideWith(
    FutureOr<Session> Function(_SessionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SessionProvider._internal(
        (ref) => create(ref as _SessionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        week: week,
        session: session,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Session> createElement() {
    return _SessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SessionProvider &&
        other.week == week &&
        other.session == session;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, week.hashCode);
    hash = _SystemHash.combine(hash, session.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _SessionRef on AutoDisposeFutureProviderRef<Session> {
  /// The parameter `week` of this provider.
  String get week;

  /// The parameter `session` of this provider.
  String get session;
}

class _SessionProviderElement extends AutoDisposeFutureProviderElement<Session>
    with _SessionRef {
  _SessionProviderElement(super.provider);

  @override
  String get week => (origin as _SessionProvider).week;
  @override
  String get session => (origin as _SessionProvider).session;
}

String _$programHash() => r'0eab236b2bc79f57b3d2ded977c3495e49583323';

/// See also [_program].
@ProviderFor(_program)
const _programProvider = _ProgramFamily();

/// See also [_program].
class _ProgramFamily extends Family<AsyncValue<Program>> {
  /// See also [_program].
  const _ProgramFamily();

  /// See also [_program].
  _ProgramProvider call(
    String programId,
  ) {
    return _ProgramProvider(
      programId,
    );
  }

  @override
  _ProgramProvider getProviderOverride(
    covariant _ProgramProvider provider,
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
  String? get name => r'_programProvider';
}

/// See also [_program].
class _ProgramProvider extends AutoDisposeFutureProvider<Program> {
  /// See also [_program].
  _ProgramProvider(
    String programId,
  ) : this._internal(
          (ref) => _program(
            ref as _ProgramRef,
            programId,
          ),
          from: _programProvider,
          name: r'_programProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$programHash,
          dependencies: _ProgramFamily._dependencies,
          allTransitiveDependencies: _ProgramFamily._allTransitiveDependencies,
          programId: programId,
        );

  _ProgramProvider._internal(
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
    FutureOr<Program> Function(_ProgramRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ProgramProvider._internal(
        (ref) => create(ref as _ProgramRef),
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
  AutoDisposeFutureProviderElement<Program> createElement() {
    return _ProgramProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ProgramProvider && other.programId == programId;
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
mixin _ProgramRef on AutoDisposeFutureProviderRef<Program> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ProgramProviderElement extends AutoDisposeFutureProviderElement<Program>
    with _ProgramRef {
  _ProgramProviderElement(super.provider);

  @override
  String get programId => (origin as _ProgramProvider).programId;
}

String _$exerciseHash() => r'700ba24650ca8c174caa5bb9b697d2fc2a128728';

/// See also [_exercise].
@ProviderFor(_exercise)
const _exerciseProvider = _ExerciseFamily();

/// See also [_exercise].
class _ExerciseFamily extends Family<AsyncValue<Exercise>> {
  /// See also [_exercise].
  const _ExerciseFamily();

  /// See also [_exercise].
  _ExerciseProvider call(
    String exerciseId,
  ) {
    return _ExerciseProvider(
      exerciseId,
    );
  }

  @override
  _ExerciseProvider getProviderOverride(
    covariant _ExerciseProvider provider,
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
  String? get name => r'_exerciseProvider';
}

/// See also [_exercise].
class _ExerciseProvider extends AutoDisposeFutureProvider<Exercise> {
  /// See also [_exercise].
  _ExerciseProvider(
    String exerciseId,
  ) : this._internal(
          (ref) => _exercise(
            ref as _ExerciseRef,
            exerciseId,
          ),
          from: _exerciseProvider,
          name: r'_exerciseProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$exerciseHash,
          dependencies: _ExerciseFamily._dependencies,
          allTransitiveDependencies: _ExerciseFamily._allTransitiveDependencies,
          exerciseId: exerciseId,
        );

  _ExerciseProvider._internal(
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
    FutureOr<Exercise> Function(_ExerciseRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ExerciseProvider._internal(
        (ref) => create(ref as _ExerciseRef),
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
  AutoDisposeFutureProviderElement<Exercise> createElement() {
    return _ExerciseProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ExerciseProvider && other.exerciseId == exerciseId;
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
mixin _ExerciseRef on AutoDisposeFutureProviderRef<Exercise> {
  /// The parameter `exerciseId` of this provider.
  String get exerciseId;
}

class _ExerciseProviderElement
    extends AutoDisposeFutureProviderElement<Exercise> with _ExerciseRef {
  _ExerciseProviderElement(super.provider);

  @override
  String get exerciseId => (origin as _ExerciseProvider).exerciseId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
