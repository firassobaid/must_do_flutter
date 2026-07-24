import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../controllers/task_list_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/common_widgets/sync_indicator.dart';
import '../../../../core/utils/haptics_util.dart';
import '../../../sharing/presentation/controllers/invitation_controller.dart';
import '../widgets/task_list_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListsAsync = ref.watch(taskListControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/branding/logo.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: AppSpacing.s),
            const Text('My Space'),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final invitesAsync = ref.watch(invitationControllerProvider);
              return invitesAsync.maybeWhen(
                data: (invites) => invites.isNotEmpty
                    ? Badge(
                        label: Text(invites.length.toString()),
                        child: IconButton(
                          onPressed: () => context.push('/invitations'),
                          icon: const Icon(Icons.notifications_outlined),
                        ),
                      )
                    : IconButton(
                        onPressed: () => context.push('/invitations'),
                        icon: const Icon(Icons.notifications_outlined),
                      ),
                orElse: () => IconButton(
                  onPressed: () => context.push('/invitations'),
                  icon: const Icon(Icons.notifications_outlined),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SyncIndicator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.xs),
            child: Text(
              'Your Lists',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(taskListControllerProvider.future),
              child: taskListsAsync.when(
                data: (lists) {
                  if (lists.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: lists.length,
                    onReorderItem: (fromIndex, toIndex) {
                      HapticsUtil.medium();
                      ref.read(taskListControllerProvider.notifier).reorder(fromIndex, toIndex);
                    },
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final animValue = Curves.easeInOut.transform(animation.value);
                          final elevation = lerpDouble(0, 8, animValue)!;
                          final scale = lerpDouble(1, 1.02, animValue)!;
                          
                          return Material(
                            elevation: elevation,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return TaskListCard(
                        list: list,
                        onTap: () {
                          HapticsUtil.light();
                          context.push('/list/${list.id}');
                        },
                      )
                          // Stagger via Animate.delay (not the effect's delay): the
                          // effect delay is part of the animation's total duration, and
                          // flutter_animate replays from scratch whenever that duration
                          // changes — which happens for every shifted item after a
                          // reorder, flashing the whole list.
                          .animate(key: ValueKey(list.id), delay: (index * 50).ms)
                          .fadeIn()
                          .slideX(begin: 0.05, end: 0);
                    },
                  );
                },
                loading: () => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
                error: (err, stack) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(child: Text('Error: $err')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticsUtil.medium();
          _showCreateListDialog(context, ref);
        },
        label: const Text('New List'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 100,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 24),
                Text(
                  'No task lists yet.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                const Text('Tap "+" to create your first one.'),
              ],
            ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
          ),
        ),
      ],
    );
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final List<Color> presets = [
      AppColors.primary,
      const Color(0xFFE07A5F), // Terracotta
      const Color(0xFF81B29A), // Sage
      const Color(0xFFF2CC8F), // Sand
      const Color(0xFF3D405B), // Deep Blue
      const Color(0xFFE9C46A), // Saffron
    ];
    Color selectedColor = presets[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Task List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'e.g., Grocery, Work, Home',
                  labelText: 'List Title',
                ),
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
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
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
                  ref.read(taskListControllerProvider.notifier).createTaskList(
                        controller.text.trim(),
                        selectedColor.toARGB32(),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create List'),
            ),
          ],
        ),
      ),
    );
  }
}
