// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskControllerHash() => r'45a3e52d72e8c3f3888c2d856c807c62aca13c0c';

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

abstract class _$TaskController
    extends BuildlessAutoDisposeStreamNotifier<List<TaskModel>> {
  late final String listId;

  Stream<List<TaskModel>> build(String listId);
}

/// See also [TaskController].
@ProviderFor(TaskController)
const taskControllerProvider = TaskControllerFamily();

/// See also [TaskController].
class TaskControllerFamily extends Family<AsyncValue<List<TaskModel>>> {
  /// See also [TaskController].
  const TaskControllerFamily();

  /// See also [TaskController].
  TaskControllerProvider call(String listId) {
    return TaskControllerProvider(listId);
  }

  @override
  TaskControllerProvider getProviderOverride(
    covariant TaskControllerProvider provider,
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
  String? get name => r'taskControllerProvider';
}

/// See also [TaskController].
class TaskControllerProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<TaskController, List<TaskModel>> {
  /// See also [TaskController].
  TaskControllerProvider(String listId)
    : this._internal(
        () => TaskController()..listId = listId,
        from: taskControllerProvider,
        name: r'taskControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskControllerHash,
        dependencies: TaskControllerFamily._dependencies,
        allTransitiveDependencies:
            TaskControllerFamily._allTransitiveDependencies,
        listId: listId,
      );

  TaskControllerProvider._internal(
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
  Stream<List<TaskModel>> runNotifierBuild(covariant TaskController notifier) {
    return notifier.build(listId);
  }

  @override
  Override overrideWith(TaskController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TaskControllerProvider._internal(
        () => create()..listId = listId,
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
  AutoDisposeStreamNotifierProviderElement<TaskController, List<TaskModel>>
  createElement() {
    return _TaskControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskControllerProvider && other.listId == listId;
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
mixin TaskControllerRef
    on AutoDisposeStreamNotifierProviderRef<List<TaskModel>> {
  /// The parameter `listId` of this provider.
  String get listId;
}

class _TaskControllerProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          TaskController,
          List<TaskModel>
        >
    with TaskControllerRef {
  _TaskControllerProviderElement(super.provider);

  @override
  String get listId => (origin as TaskControllerProvider).listId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
