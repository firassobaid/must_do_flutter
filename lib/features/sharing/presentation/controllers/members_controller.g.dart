// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listMembersHash() => r'29f4f1955e0ad9d4a01ecf8203cfa0fde64eb48e';

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

/// See also [listMembers].
@ProviderFor(listMembers)
const listMembersProvider = ListMembersFamily();

/// See also [listMembers].
class ListMembersFamily extends Family<AsyncValue<List<UserModel>>> {
  /// See also [listMembers].
  const ListMembersFamily();

  /// See also [listMembers].
  ListMembersProvider call(String listId) {
    return ListMembersProvider(listId);
  }

  @override
  ListMembersProvider getProviderOverride(
    covariant ListMembersProvider provider,
  ) {
    return call(provider.listId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listMembersProvider';
}

/// See also [listMembers].
class ListMembersProvider extends AutoDisposeStreamProvider<List<UserModel>> {
  /// See also [listMembers].
  ListMembersProvider(String listId)
    : this._internal(
        (ref) => listMembers(ref as ListMembersRef, listId),
        from: listMembersProvider,
        name: r'listMembersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$listMembersHash,
        dependencies: ListMembersFamily._dependencies,
        allTransitiveDependencies:
            ListMembersFamily._allTransitiveDependencies,
        listId: listId,
      );

  ListMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listId,
  }) : super.internal();

  final String listId;

  @override
  Override overrideWith(
    Stream<List<UserModel>> Function(ListMembersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListMembersProvider._internal(
        (ref) => create(ref as ListMembersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listId: listId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<UserModel>> createElement() {
    return _ListMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListMembersProvider && other.listId == listId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListMembersRef on AutoDisposeStreamProviderRef<List<UserModel>> {
  /// The parameter `listId` of this provider.
  String get listId;
}

class _ListMembersProviderElement
    extends AutoDisposeStreamProviderElement<List<UserModel>>
    with ListMembersRef {
  _ListMembersProviderElement(super.provider);

  @override
  String get listId => (origin as ListMembersProvider).listId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
