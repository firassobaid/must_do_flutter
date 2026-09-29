import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task_model.dart';
import 'task_list_controller.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

part 'task_controller.g.dart';

@riverpod
class TaskController extends _$TaskController {
  @override
  Stream<List<TaskModel>> build(String listId) {
    return ref.watch(taskRepositoryProvider).watchTasks(listId);
  }

  Future<void> createTask(String listId, String title, {String? description}) async {
    final authState = ref.read(authStateChangesProvider);
    final user = authState.value;
    if (user == null) return;

    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdBy: user.uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(taskRepositoryProvider).createTask(listId, newTask);
  }

  Future<void> toggleTask(String listId, TaskModel task) async {
    final updatedTask = task.copyWith(
      isDone: !task.isDone,
      updatedAt: DateTime.now(),
    );
    await ref.read(taskRepositoryProvider).updateTask(listId, updatedTask);
  }

  Future<void> deleteTask(String listId, String taskId) async {
    await ref.read(taskRepositoryProvider).deleteTask(listId, taskId);
  }

  Future<void> updateTask(String listId, TaskModel task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await ref.read(taskRepositoryProvider).updateTask(listId, updatedTask);
  }
}
