import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<UserModel?> build() async {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    
    if (user == null) return null;
    
    return ref.read(authRepositoryProvider).getCurrentUserDoc(user.uid);
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updateUserDoc(updatedUser);
      return updatedUser;
    });
  }
}
