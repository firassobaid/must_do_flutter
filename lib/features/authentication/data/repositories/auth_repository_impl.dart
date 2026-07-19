import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/exceptions/app_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Sign in aborted by user');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) throw AuthException('Sign in failed');

      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        joinedAt: DateTime.now(),
      );

      // Check if user exists in Firestore, if not create
      final existingUser = await getCurrentUserDoc(user.uid);
      if (existingUser == null) {
        await createUserDoc(userModel);
      }

      return userModel;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user == null) throw AuthException('Sign up failed');

      // Set display name in Firebase Auth
      await user.updateDisplayName(displayName);

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        joinedAt: DateTime.now(),
      );

      await createUserDoc(userModel);
      return userModel;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw AuthException(e.message ?? 'An error occurred during sign up', e.code);
      }
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) throw AuthException('Sign in failed');

      final existingUser = await getCurrentUserDoc(user.uid);
      if (existingUser == null) {
        throw AuthException('User profile not found in database');
      }

      return existingUser;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw AuthException(e.message ?? 'An error occurred during sign in', e.code);
      }
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUserDoc(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  @override
  Stream<UserModel?> watchUserDoc(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null,
        );
  }

  @override
  Future<void> createUserDoc(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  @override
  Future<void> updateUserDoc(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }

  @override
  Future<void> updateFCMToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
  }
}
