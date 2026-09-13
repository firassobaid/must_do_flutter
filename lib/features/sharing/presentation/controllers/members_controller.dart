import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import 'invitation_controller.dart' show sharingRepositoryProvider;

part 'members_controller.g.dart';

@riverpod
Stream<List<UserModel>> listMembers(ListMembersRef ref, String listId) {
  final sharingRepository = ref.watch(sharingRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);

  return sharingRepository.watchMemberUserIds(listId).asyncMap((userIds) async {
    final users = await Future.wait(userIds.map(authRepository.getCurrentUserDoc));
    return users.whereType<UserModel>().toList();
  });
}
