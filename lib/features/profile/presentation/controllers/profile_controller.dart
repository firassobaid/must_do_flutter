import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Stream<UserModel?> build() {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;

    if (user == null) return Stream.value(null);

    // Watch the user doc instead of a one-shot get(): snapshots() serve the
    // local cache when the backend is unreachable and update in real time.
    // If the doc doesn't exist (or isn't cached yet while offline), fall back
    // to the Firebase Auth profile so the page always renders.
    return ref.watch(authRepositoryProvider).watchUserDoc(user.uid).map(
          (doc) =>
              doc ??
              UserModel(
                uid: user.uid,
                email: user.email ?? '',
                displayName: user.displayName,
                photoUrl: user.photoURL,
              ),
        );
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    // No manual state update needed: the watched snapshot stream emits the
    // change immediately via Firestore's latency compensation.
    await ref.read(authRepositoryProvider).updateUserDoc(updatedUser);
  }
}
