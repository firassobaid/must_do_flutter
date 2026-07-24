import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/common_widgets/cozy_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/task_list_model.dart';
import '../controllers/task_list_controller.dart';

class TaskListCard extends ConsumerWidget {
  final TaskListModel list;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TaskListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(taskListProgressProvider(list.id));
    final color = Color(list.colorValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
      child: CozyCard(
        color: color.withValues(alpha: 0.15),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.list_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          color: color.withValues(alpha: 0.9),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  progressAsync.when(
                    data: (stats) {
                      final percent = stats.total == 0 ? 0.0 : stats.done / stats.total;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stats.total == 0 
                                ? 'No tasks yet' 
                                : '${stats.done} of ${stats.total} tasks completed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percent,
                              backgroundColor: color.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(height: 20),
                    error: (error, stackTrace) => const SizedBox(height: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            if (onDelete != null || onEdit != null)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: color.withValues(alpha: 0.6),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete?.call();
                  } else if (value == 'edit') {
                    onEdit?.call();
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
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
                  if (onDelete != null)
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
              )
            else
              Icon(
                Icons.drag_indicator_rounded,
                color: color.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}
