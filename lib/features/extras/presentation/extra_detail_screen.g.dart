// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extra_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$extraHash() => r'4e0fa130d4bed50aa92bc8759a885bde1a91ecda';

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

/// See also [_extra].
@ProviderFor(_extra)
const _extraProvider = _ExtraFamily();

/// See also [_extra].
class _ExtraFamily extends Family<AsyncValue<ExtraItem?>> {
  /// See also [_extra].
  const _ExtraFamily();

  /// See also [_extra].
  _ExtraProvider call(
    String extraId,
  ) {
    return _ExtraProvider(
      extraId,
    );
  }

  @override
  _ExtraProvider getProviderOverride(
    covariant _ExtraProvider provider,
  ) {
    return call(
      provider.extraId,
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
  String? get name => r'_extraProvider';
}

/// See also [_extra].
class _ExtraProvider extends AutoDisposeFutureProvider<ExtraItem?> {
  /// See also [_extra].
  _ExtraProvider(
    String extraId,
  ) : this._internal(
          (ref) => _extra(
            ref as _ExtraRef,
            extraId,
          ),
          from: _extraProvider,
          name: r'_extraProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$extraHash,
          dependencies: _ExtraFamily._dependencies,
          allTransitiveDependencies: _ExtraFamily._allTransitiveDependencies,
          extraId: extraId,
        );

  _ExtraProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.extraId,
  }) : super.internal();

  final String extraId;

  @override
  Override overrideWith(
    FutureOr<ExtraItem?> Function(_ExtraRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ExtraProvider._internal(
        (ref) => create(ref as _ExtraRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        extraId: extraId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ExtraItem?> createElement() {
    return _ExtraProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ExtraProvider && other.extraId == extraId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, extraId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _ExtraRef on AutoDisposeFutureProviderRef<ExtraItem?> {
  /// The parameter `extraId` of this provider.
  String get extraId;
}

class _ExtraProviderElement extends AutoDisposeFutureProviderElement<ExtraItem?>
    with _ExtraRef {
  _ExtraProviderElement(super.provider);

  @override
  String get extraId => (origin as _ExtraProvider).extraId;
}

String _$exercisesHash() => r'86a1fafe4897fadf23d1ebe4fc6a122b41981d5e';

/// See also [_exercises].
@ProviderFor(_exercises)
final _exercisesProvider = AutoDisposeFutureProvider<List<Exercise>>.internal(
  _exercises,
  name: r'_exercisesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$exercisesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef _ExercisesRef = AutoDisposeFutureProviderRef<List<Exercise>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
