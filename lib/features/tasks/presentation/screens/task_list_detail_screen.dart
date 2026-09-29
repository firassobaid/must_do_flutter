import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/task_list_model.dart';
import '../../data/models/task_model.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_list_controller.dart';
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

    final currentList = listAsync.whenOrNull(
      data: (lists) => lists.firstWhere((l) => l.id == listId),
    );
    final listTitle = currentList?.title ?? 'Loading...';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(listTitle),
        actions: [
          IconButton(
            tooltip: 'Members',
            onPressed: () => context.push('/list/$listId/members'),
            icon: const Icon(Icons.people_outline),
          ),
          IconButton(
            tooltip: 'Invite collaborator',
            onPressed: () => showDialog(
              context: context,
              builder: (context) =>
                  ShareListDialog(listId: listId, listTitle: listTitle),
            ),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
          Builder(
            builder: (iconContext) => IconButton(
              tooltip: 'Share',
              onPressed: () =>
                  _shareList(iconContext, listTitle, tasksAsync.value ?? []),
              icon: const Icon(Icons.share_outlined),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDeleteList(context, ref, listTitle);
              } else if (value == 'edit' && currentList != null) {
                _showEditListDialog(context, ref, currentList);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Edit List'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete List', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SyncIndicator(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(taskControllerProvider(listId).future),
                child: tasksAsync.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: const Center(
                              child: Text('No tasks in this list.'),
                            ),
                          ),
                        ],
                      );
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
                              onEdit: () =>
                                  _showEditTaskDialog(context, ref, task),
                            )
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideX(begin: 0.1, end: 0);
                      },
                    );
                  },
                  loading: () => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                  error: (err, stack) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(child: Text('Error: $err')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticsUtil.medium();
          _showAddTaskDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Opens the platform share sheet with the list rendered as text.
  void _shareList(
    BuildContext context,
    String listTitle,
    List<TaskModel> tasks,
  ) {
    final buffer = StringBuffer('📝 $listTitle\n\n');
    if (tasks.isEmpty) {
      buffer.writeln('(no tasks yet)');
    } else {
      for (final task in tasks) {
        buffer.writeln('${task.isDone ? '✅' : '⬜'} ${task.title}');
      }
    }
    buffer.write('\nShared from Must Do');

    // Anchor for the iPad share popover.
    final box = context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject: listTitle,
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      ),
    );
  }

  void _showEditListDialog(
    BuildContext context,
    WidgetRef ref,
    TaskListModel list,
  ) {
    final controller = TextEditingController(text: list.title);
    final List<Color> presets = [
      AppColors.primary,
      const Color(0xFFE07A5F),
      const Color(0xFF81B29A),
      const Color(0xFFF2CC8F),
      const Color(0xFF3D405B),
      const Color(0xFFE9C46A),
    ];
    Color selectedColor = Color(list.colorValue);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Task List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'List Title'),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Choose Color',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: presets.map((color) {
                  final isSelected =
                      selectedColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 2,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
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
                      .read(taskListControllerProvider.notifier)
                      .updateTaskList(
                        list.copyWith(
                          title: controller.text.trim(),
                          colorValue: selectedColor.toARGB32(),
                        ),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteList(BuildContext context, WidgetRef ref, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List?'),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(taskListControllerProvider.notifier)
                  .deleteTaskList(listId);
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop screen back to Home
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(
    BuildContext context,
    WidgetRef ref,
    TaskModel task,
  ) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(
      text: task.description ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                ref
                    .read(taskControllerProvider(listId).notifier)
                    .updateTask(
                      listId,
                      task.copyWith(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
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
