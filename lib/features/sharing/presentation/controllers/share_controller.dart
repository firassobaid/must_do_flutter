import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/invitation_model.dart';
import 'invitation_controller.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

part 'share_controller.g.dart';

@riverpod
class ShareController extends _$ShareController {
  @override
  FutureOr<void> build() {}

  Future<void> sendInvitation({
    required String receiverEmail,
    required String listId,
    required String listTitle,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = ref.read(authStateChangesProvider).value;
      if (user == null) throw Exception('User not logged in');

      final invitation = InvitationModel(
        id: const Uuid().v4(),
        senderId: user.uid,
        senderName: user.displayName ?? 'Someone',
        receiverEmail: receiverEmail,
        listId: listId,
        listTitle: listTitle,
        createdAt: DateTime.now(),
      );

      await ref.read(sharingRepositoryProvider).sendInvitation(invitation);
    });
  }
}
