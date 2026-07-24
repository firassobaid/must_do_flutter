import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task_list_model.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

part 'task_list_controller.g.dart';

@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  return TaskRepositoryImpl();
}

@riverpod
Stream<({int total, int done})> taskListProgress(TaskListProgressRef ref, String listId) {
  return ref.watch(taskRepositoryProvider).watchTasks(listId).map((tasks) {
    return (
      total: tasks.length,
      done: tasks.where((t) => t.isDone).length,
    );
  });
}

@riverpod
class TaskListController extends _$TaskListController {
  bool _isReordering = false;

  @override
  Stream<List<TaskListModel>> build() {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    
    if (user == null) return Stream.value([]);
    
    // We listen to the repository stream but only update the state if we're not reordering.
    return ref.watch(taskRepositoryProvider).watchTaskLists(user.uid).where((_) => !_isReordering);
  }

  Future<void> createTaskList(String title, int colorValue) async {
    final authState = ref.read(authStateChangesProvider);
    final user = authState.value;
    if (user == null) return;

    final lists = state.value ?? [];
    final maxOrder = lists.isEmpty ? 0 : lists.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b);

    final newList = TaskListModel(
      id: const Uuid().v4(),
      title: title,
      colorValue: colorValue,
      ownerId: user.uid,
      sortOrder: maxOrder + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(taskRepositoryProvider).createTaskList(newList);
  }

  /// [fromIndex]/[toIndex] follow onReorderItem semantics: [toIndex] is
  /// already adjusted for the removal of the item at [fromIndex].
  Future<void> reorder(int fromIndex, int toIndex) async {
    final lists = state.value;
    if (lists == null) return;

    final updatedLists = List<TaskListModel>.from(lists);
    final item = updatedLists.removeAt(fromIndex);
    updatedLists.insert(toIndex, item);

    // 1. Set reordering flag to block stale stream updates
    _isReordering = true;

    // 2. Update sortOrder locally
    final reorderedWithIndices = updatedLists.asMap().entries.map((entry) {
      return entry.value.copyWith(sortOrder: entry.key);
    }).toList();

    // 3. Update UI immediately
    state = AsyncValue.data(reorderedWithIndices);

    try {
      // 4. Save to Firestore
      await ref.read(taskRepositoryProvider).reorderTaskLists(reorderedWithIndices);
      
      // 5. Short delay to allow Firestore to emit the *new* state before we resume listening
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      _isReordering = false;
    }
  }

  Future<void> deleteTaskList(String listId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    
    await ref.read(taskRepositoryProvider).deleteTaskList(user.uid, listId);
  }

  Future<void> updateTaskList(TaskListModel list) async {
    await ref.read(taskRepositoryProvider).updateTaskList(list);
  }
}
