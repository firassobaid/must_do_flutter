import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_list_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/common_widgets/sync_indicator.dart';
import '../../../../core/utils/haptics_util.dart';
import '../widgets/task_list_item.dart';
import '../../../sharing/presentation/widgets/share_list_dialog.dart';

class TaskListDetailScreen extends ConsumerWidget {
  final String listId;

  const TaskListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskControllerProvider(listId));
    final listAsync = ref.watch(taskListControllerProvider);

    final listTitle = listAsync.when(
      data: (lists) => lists.firstWhere((l) => l.id == listId).title,
      loading: () => 'Loading...',
      error: (error, stackTrace) => 'Error',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(listTitle),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ShareListDialog(
                listId: listId,
                listTitle: listTitle,
              ),
            ),
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncIndicator(),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(child: Text('No tasks in this list.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskListItem(
                      task: task,
                      onToggle: (_) => ref
                          .read(taskControllerProvider(listId).notifier)
                          .toggleTask(listId, task),
                      onDelete: () => ref
                          .read(taskControllerProvider(listId).notifier)
                          .deleteTask(listId, task.id),
                    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticsUtil.medium();
          _showAddTaskDialog(context, ref);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'What needs to be done?'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(taskControllerProvider(listId).notifier)
                    .createTask(listId, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
