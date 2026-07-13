import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/share_controller.dart';
import '../../../../core/constants/app_colors.dart';

class ShareListDialog extends ConsumerWidget {
  final String listId;
  final String listTitle;

  const ShareListDialog({
    super.key,
    required this.listId,
    required this.listTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final shareState = ref.watch(shareControllerProvider);

    ref.listen(shareControllerProvider, (previous, next) {
      if (next is AsyncData) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitation sent!')),
        );
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }
    });

    return AlertDialog(
      title: const Text('Invite Collaborator'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Share this list with someone else via their email address.'),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Email address',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: shareState.isLoading
              ? null
              : () {
                  if (controller.text.isNotEmpty) {
                    ref.read(shareControllerProvider.notifier).sendInvitation(
                          receiverEmail: controller.text.trim(),
                          listId: listId,
                          listTitle: listTitle,
                        );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: shareState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Send Invite'),
        ),
      ],
    );
  }
}
