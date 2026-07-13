import '../../data/models/invitation_model.dart';

abstract class SharingRepository {
  Stream<List<InvitationModel>> watchPendingInvitations(String userEmail);
  
  Future<void> sendInvitation(InvitationModel invitation);
  
  Future<void> respondToInvitation(InvitationModel invitation, InvitationStatus response);
}
