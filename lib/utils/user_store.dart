/// Firebase-backed user authentication and Firestore profile storage.
///
/// Replaces the old local encrypted KV store with:
/// - [FirebaseAuth] for email/password registration, login, and password reset.
/// - [Cloud Firestore] for persisting user profile data (name, email).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStore {
  static final UserStore _instance = UserStore._internal();
  factory UserStore() => _instance;
  UserStore._internal();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// The currently signed-in Firebase user, or `null`.
  User? get currentUser => _auth.currentUser;

  // ── Registration ──────────────────────────────────────────────────────────

  /// Creates a new account with [email] and [password], then writes a profile
  /// document to Firestore `users/{uid}` containing the user's [name] and
  /// [email].
  ///
  /// Throws [FirebaseAuthException] on failure (e.g. email-already-in-use).
  Future<void> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    // Store profile in Firestore
    await _firestore.collection('users').doc(uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Also set the display name on the Firebase Auth profile
    await credential.user!.updateDisplayName(name.trim());
  }

  // ── Authentication ────────────────────────────────────────────────────────

  /// Signs in with [email] and [password].
  ///
  /// Throws [FirebaseAuthException] on failure (e.g. wrong-password).
  Future<void> authenticate(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Password Reset ────────────────────────────────────────────────────────

  /// Sends a password reset email to [email] via Firebase.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Firestore Profile ─────────────────────────────────────────────────────

  /// Returns the Firestore profile for the currently logged-in user.
  ///
  /// Returns `null` if no user is logged in or the document doesn't exist.
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Writes or merges a profile document for a user (used by Google Sign-In
  /// to create a Firestore profile on first login).
  Future<void> ensureProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
