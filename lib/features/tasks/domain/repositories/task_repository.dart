import '../../data/models/task_list_model.dart';
import '../../data/models/task_model.dart';

abstract class TaskRepository {
  Stream<List<TaskListModel>> watchTaskLists(String userId);
  
  Stream<List<TaskModel>> watchTasks(String listId);
  
  Future<void> createTaskList(TaskListModel list);
  
  Future<void> updateTaskList(TaskListModel list);
  
  Future<void> deleteTaskList(String listId);
  
  Future<void> reorderTaskLists(List<TaskListModel> lists);
  
  Future<void> createTask(String listId, TaskModel task);
  
  Future<void> updateTask(String listId, TaskModel task);
  
  Future<void> deleteTask(String listId, String taskId);
}
