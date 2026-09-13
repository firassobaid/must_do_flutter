import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
      if (existingUser != null) return existingUser;

      // Profile doc is missing (e.g. the account was created outside the app).
      // Recreate it from the auth user rather than failing an otherwise valid
      // sign in, mirroring the Google sign in path.
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        joinedAt: DateTime.now(),
      );
      await createUserDoc(userModel);
      return userModel;
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

  /// A doc that can't be parsed into a [UserModel] (missing the required uid or
  /// email) is reported as absent, so callers recreate it or fall back to the
  /// Firebase Auth profile instead of surfacing a cast error.
  UserModel? _parseUserDoc(Map<String, dynamic>? data) {
    if (data == null) return null;
    try {
      return UserModel.fromJson(data);
    } catch (e) {
      debugPrint('Ignoring malformed user doc: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> getCurrentUserDoc(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return _parseUserDoc(doc.data());
  }

  @override
  Stream<UserModel?> watchUserDoc(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? _parseUserDoc(doc.data()) : null,
        );
  }

  @override
  Future<void> createUserDoc(UserModel user) async {
    // Merge so healing an incomplete doc keeps unrelated fields (e.g. fcmToken).
    await _firestore.collection('users').doc(user.uid).set(
          user.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> updateUserDoc(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toJson());
  }

  @override
  Future<void> updateFCMToken(String uid, String token) async {
    // update() rather than set(merge: true): a token sync must never bring a
    // profile doc into existence, since a doc holding only a token is missing
    // the required uid/email and cannot be parsed back into a UserModel.
    // Callers treat a missing doc as a no-op.
    await _firestore.collection('users').doc(uid).update({'fcmToken': token});
  }
}
