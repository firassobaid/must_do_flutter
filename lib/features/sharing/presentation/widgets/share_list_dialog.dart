import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/share_controller.dart';
import '../../../../core/constants/app_colors.dart';

class ShareListDialog extends ConsumerStatefulWidget {
  final String listId;
  final String listTitle;

  const ShareListDialog({
    super.key,
    required this.listId,
    required this.listTitle,
  });

  @override
  ConsumerState<ShareListDialog> createState() => _ShareListDialogState();
}

class _ShareListDialogState extends ConsumerState<ShareListDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus after the dialog's entrance transition finishes, so it doesn't
    // animate at the same time as the keyboard sliding in.
    Future.delayed(const Duration(milliseconds: 200), _focusNode.requestFocus);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shareState = ref.watch(shareControllerProvider);

    ref.listen(shareControllerProvider, (previous, next) {
      if (next is AsyncData) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invitation sent!')));
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });

    return AlertDialog(
      title: const Text('Invite Collaborator'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share this list with someone else via their email address.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              hintText: 'Email address',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
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
                  if (_controller.text.isNotEmpty) {
                    ref
                        .read(shareControllerProvider.notifier)
                        .sendInvitation(
                          receiverEmail: _controller.text.trim(),
                          listId: widget.listId,
                          listTitle: widget.listTitle,
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Send Invite'),
        ),
      ],
    );
  }
}
