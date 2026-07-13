import '../repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class SignInWithGoogle {
  final AuthRepository _repository;

  SignInWithGoogle(this._repository);

  Future<UserModel> call() {
    return _repository.signInWithGoogle();
  }
}
