import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/sharing_repository.dart';
import '../models/invitation_model.dart';

class SharingRepositoryImpl implements SharingRepository {
  final FirebaseFirestore _firestore;

  SharingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<InvitationModel>> watchPendingInvitations(String userEmail) {
    return _firestore
        .collection('invitations')
        .where('receiverEmail', isEqualTo: userEmail)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InvitationModel.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> sendInvitation(InvitationModel invitation) async {
    await _firestore
        .collection('invitations')
        .doc(invitation.id)
        .set(invitation.toJson());
  }

  @override
  Future<void> respondToInvitation(InvitationModel invitation, InvitationStatus response) async {
    final batch = _firestore.batch();
    
    // Update invitation status
    final invitationRef = _firestore.collection('invitations').doc(invitation.id);
    batch.update(invitationRef, {'status': response.name});
    
    if (response == InvitationStatus.accepted) {
      // Find the user ID based on email (or wait until they accept)
      // For simplicity in this demo, we assume the user accepting is the receiver.
      // In production, you might need a lookup for uid by email.
      // We'll use a placeholder or the current user's uid in the controller.
    }
    
    await batch.commit();
  }
  
  // Helper for actual membership creation when accepted
  Future<void> createMembership(String userId, String listId) async {
    await _firestore.collection('memberships').doc('${userId}_$listId').set({
      'userId': userId,
      'listId': listId,
      'role': 'editor',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }
}
