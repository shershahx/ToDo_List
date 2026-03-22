/// Google Sign-In + Firebase Auth service.
///
/// Wraps [GoogleSignIn] and [FirebaseAuth] into a simple singleton that the
/// login and signup screens can call without knowing Firebase internals.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final _googleSignIn = GoogleSignIn();
  final _firebaseAuth = FirebaseAuth.instance;

  /// Triggers the Google Sign-In flow and authenticates with Firebase.
  ///
  /// Returns the user's email on success, or `null` if the user cancels.
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user?.email;
    } catch (e) {
      // Let the caller handle the error via a null return
      return null;
    }
  }

  /// Signs out of both Google and Firebase.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Whether a Firebase user is currently signed in.
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// The currently signed-in user's email, or `null`.
  String? get currentEmail => _firebaseAuth.currentUser?.email;
}
