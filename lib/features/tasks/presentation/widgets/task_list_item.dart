import 'package:flutter/material.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../data/models/task_model.dart';

class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: task.isDone,
            onChanged: (val) {
              HapticsUtil.light();
              onToggle(val);
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                color: task.isDone 
                    ? Theme.of(context).colorScheme.onSurfaceVariant 
                    : Theme.of(context).colorScheme.onSurface,
              ),
        ),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline, 
            size: 20, 
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            HapticsUtil.medium();
            onDelete();
          },
        ),
      ),
    );
  }
}
