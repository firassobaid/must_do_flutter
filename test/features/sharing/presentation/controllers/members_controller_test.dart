import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:must_do/features/authentication/data/models/user_model.dart';
import 'package:must_do/features/authentication/domain/repositories/auth_repository.dart';
import 'package:must_do/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:must_do/features/sharing/data/models/invitation_model.dart';
import 'package:must_do/features/sharing/domain/repositories/sharing_repository.dart';
import 'package:must_do/features/sharing/presentation/controllers/invitation_controller.dart';
import 'package:must_do/features/sharing/presentation/controllers/members_controller.dart';

class _FakeSharingRepository implements SharingRepository {
  final _memberIdsController = StreamController<List<String>>.broadcast();

  void emitMemberIds(List<String> ids) => _memberIdsController.add(ids);

  @override
  Stream<List<String>> watchMemberUserIds(String listId) => _memberIdsController.stream;

  @override
  Stream<List<InvitationModel>> watchPendingInvitations(String userEmail) => const Stream.empty();

  @override
  Future<void> sendInvitation(InvitationModel invitation) async {}

  @override
  Future<void> respondToInvitation(InvitationModel invitation, InvitationStatus response) async {}
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.usersByUid);

  final Map<String, UserModel> usersByUid;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<UserModel> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async =>
      throw UnimplementedError();

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel?> getCurrentUserDoc(String uid) async => usersByUid[uid];

  @override
  Stream<UserModel?> watchUserDoc(String uid) => Stream.value(usersByUid[uid]);

  @override
  Future<void> createUserDoc(UserModel user) async {}

  @override
  Future<void> updateUserDoc(UserModel user) async {}

  @override
  Future<void> updateFCMToken(String uid, String token) async {}
}

void main() {
  test('listMembers resolves membership user-ids into UserModels, dropping missing profiles', () async {
    final fakeSharing = _FakeSharingRepository();
    final fakeAuth = _FakeAuthRepository({
      'owner-1': UserModel(uid: 'owner-1', email: 'owner@example.com', displayName: 'Owner One'),
      'member-2': UserModel(uid: 'member-2', email: 'member2@example.com', displayName: 'Member Two'),
      // 'ghost-3' has no profile doc and must be silently dropped, not crash.
    });

    final container = ProviderContainer(overrides: [
      sharingRepositoryProvider.overrideWithValue(fakeSharing),
      authRepositoryProvider.overrideWithValue(fakeAuth),
    ]);
    addTearDown(container.dispose);

    final results = <List<UserModel>>[];
    final sub = container.listen(
      listMembersProvider('list-1'),
      (previous, next) {
        next.whenData(results.add);
      },
      fireImmediately: true,
    );
    addTearDown(sub.close);

    fakeSharing.emitMemberIds(['owner-1', 'member-2', 'ghost-3']);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(results, isNotEmpty);
    expect(results.last.map((u) => u.uid).toList(), ['owner-1', 'member-2']);
  });
}
