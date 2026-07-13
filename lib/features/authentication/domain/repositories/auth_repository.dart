import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  
  Future<UserModel> signInWithGoogle();
  
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String displayName);
  
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  
  Future<void> signOut();
  
  Future<UserModel?> getCurrentUserDoc(String uid);
  
  Future<void> createUserDoc(UserModel user);

  Future<void> updateUserDoc(UserModel user);

  Future<void> updateFCMToken(String uid, String token);
}
