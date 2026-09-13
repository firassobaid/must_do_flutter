import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../tasks/presentation/controllers/task_list_controller.dart';
import '../controllers/members_controller.dart';

class MembersScreen extends ConsumerWidget {
  final String listId;

  const MembersScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(listMembersProvider(listId));
    final listsAsync = ref.watch(taskListControllerProvider);
    final ownerId = listsAsync.whenOrNull(
      data: (lists) => lists.firstWhere((l) => l.id == listId).ownerId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('No members yet.'));
          }

          final sortedMembers = [...members]
            ..sort((a, b) {
              if (a.uid == ownerId) return -1;
              if (b.uid == ownerId) return 1;
              return 0;
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedMembers.length,
            itemBuilder: (context, index) {
              final member = sortedMembers[index];
              final isOwner = member.uid == ownerId;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                    backgroundImage: member.photoUrl != null
                        ? CachedNetworkImageProvider(member.photoUrl!)
                        : null,
                    child: member.photoUrl == null
                        ? const Icon(Icons.person, color: AppColors.primary)
                        : null,
                  ),
                  title: Text(member.displayName ?? 'Anonymous User'),
                  subtitle: Text(member.email),
                  trailing: isOwner
                      ? Chip(
                          label: const Text('Owner'),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(color: AppColors.primary),
                        )
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
