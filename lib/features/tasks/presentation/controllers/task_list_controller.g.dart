// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskRepositoryHash() => r'07b4d1d8e043937f963e52f66b966b9aaa3cebc5';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = AutoDisposeProvider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskRepositoryRef = AutoDisposeProviderRef<TaskRepository>;
String _$taskListProgressHash() => r'51855976f6cd36953d358796ce4f8a39afe3e78d';

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

/// See also [taskListProgress].
@ProviderFor(taskListProgress)
const taskListProgressProvider = TaskListProgressFamily();

/// See also [taskListProgress].
class TaskListProgressFamily
    extends Family<AsyncValue<({int total, int done})>> {
  /// See also [taskListProgress].
  const TaskListProgressFamily();

  /// See also [taskListProgress].
  TaskListProgressProvider call(String listId) {
    return TaskListProgressProvider(listId);
  }

  @override
  TaskListProgressProvider getProviderOverride(
    covariant TaskListProgressProvider provider,
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
  String? get name => r'taskListProgressProvider';
}

/// See also [taskListProgress].
class TaskListProgressProvider
    extends AutoDisposeStreamProvider<({int total, int done})> {
  /// See also [taskListProgress].
  TaskListProgressProvider(String listId)
    : this._internal(
        (ref) => taskListProgress(ref as TaskListProgressRef, listId),
        from: taskListProgressProvider,
        name: r'taskListProgressProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$taskListProgressHash,
        dependencies: TaskListProgressFamily._dependencies,
        allTransitiveDependencies:
            TaskListProgressFamily._allTransitiveDependencies,
        listId: listId,
      );

  TaskListProgressProvider._internal(
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
    Stream<({int total, int done})> Function(TaskListProgressRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskListProgressProvider._internal(
        (ref) => create(ref as TaskListProgressRef),
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
  AutoDisposeStreamProviderElement<({int total, int done})> createElement() {
    return _TaskListProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskListProgressProvider && other.listId == listId;
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
mixin TaskListProgressRef
    on AutoDisposeStreamProviderRef<({int total, int done})> {
  /// The parameter `listId` of this provider.
  String get listId;
}

class _TaskListProgressProviderElement
    extends AutoDisposeStreamProviderElement<({int total, int done})>
    with TaskListProgressRef {
  _TaskListProgressProviderElement(super.provider);

  @override
  String get listId => (origin as TaskListProgressProvider).listId;
}

String _$taskListControllerHash() =>
    r'4c6e5e04855efa382b86738c91933635405dced3';

/// See also [TaskListController].
@ProviderFor(TaskListController)
final taskListControllerProvider =
    AutoDisposeStreamNotifierProvider<
      TaskListController,
      List<TaskListModel>
    >.internal(
      TaskListController.new,
      name: r'taskListControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskListControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskListController = AutoDisposeStreamNotifier<List<TaskListModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
