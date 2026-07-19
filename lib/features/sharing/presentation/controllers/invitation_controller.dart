import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/invitation_model.dart';
import '../../data/repositories/sharing_repository_impl.dart';
import '../../domain/repositories/sharing_repository.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

part 'invitation_controller.g.dart';

@riverpod
SharingRepository sharingRepository(SharingRepositoryRef ref) {
  return SharingRepositoryImpl();
}

@riverpod
class InvitationController extends _$InvitationController {
  @override
  Stream<List<InvitationModel>> build() {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    
    if (user == null || user.email == null) return Stream.value([]);
    
    return ref.watch(sharingRepositoryProvider).watchPendingInvitations(user.email!.toLowerCase());
  }

  Future<void> acceptInvitation(InvitationModel invitation) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    await ref.read(sharingRepositoryProvider).respondToInvitation(
      invitation, 
      InvitationStatus.accepted
    );
    
    // Create the membership
    await (ref.read(sharingRepositoryProvider) as SharingRepositoryImpl)
        .createMembership(user.uid, invitation.listId);
  }

  Future<void> declineInvitation(InvitationModel invitation) async {
    await ref.read(sharingRepositoryProvider).respondToInvitation(
      invitation, 
      InvitationStatus.declined
    );
  }
}
