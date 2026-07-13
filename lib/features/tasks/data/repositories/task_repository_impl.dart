import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_list_model.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<TaskListModel>> watchTaskLists(String userId) {
    // We query the memberships collection to find which lists the user belongs to
    return _firestore
        .collection('memberships')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final listIds = snapshot.docs.map((doc) => doc.data()['listId'] as String).toList();
      
      if (listIds.isEmpty) return [];

      // Fetch the actual task list documents
      // Note: Firestore 'in' queries are limited to 30 items. 
      // For a premium app, a user having >30 lists is possible, but we'll start here.
      final listsSnapshot = await _firestore
          .collection('task_lists')
          .where(FieldPath.documentId, whereIn: listIds)
          .get();

      return listsSnapshot.docs
          .map((doc) => TaskListModel.fromJson(doc.data()))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  @override
  Stream<List<TaskModel>> watchTasks(String listId) {
    return _firestore
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> createTaskList(TaskListModel list) async {
    final batch = _firestore.batch();
    
    final listRef = _firestore.collection('task_lists').doc(list.id);
    batch.set(listRef, list.toJson());
    
    final membershipRef = _firestore.collection('memberships').doc('${list.ownerId}_${list.id}');
    batch.set(membershipRef, {
      'userId': list.ownerId,
      'listId': list.id,
      'role': 'owner',
      'joinedAt': FieldValue.serverTimestamp(),
    });
    
    await batch.commit();
  }

  @override
  Future<void> updateTaskList(TaskListModel list) async {
    await _firestore
        .collection('task_lists')
        .doc(list.id)
        .update(list.toJson());
  }

  @override
  Future<void> deleteTaskList(String listId) async {
    // Note: In production, you'd use a Cloud Function to clean up sub-collections and memberships.
    // For now, we delete the main document.
    await _firestore.collection('task_lists').doc(listId).delete();
  }

  @override
  Future<void> reorderTaskLists(List<TaskListModel> lists) async {
    final batch = _firestore.batch();
    for (var list in lists) {
      final ref = _firestore.collection('task_lists').doc(list.id);
      batch.update(ref, {'sortOrder': list.sortOrder});
    }
    await batch.commit();
  }

  @override
  Future<void> createTask(String listId, TaskModel task) async {
    await _firestore
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }

  @override
  Future<void> updateTask(String listId, TaskModel task) async {
    await _firestore
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toJson());
  }

  @override
  Future<void> deleteTask(String listId, String taskId) async {
    await _firestore
        .collection('task_lists')
        .doc(listId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
