import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static User? get currentUser {
    return _auth.currentUser;
  }

  static Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  static Future<UserCredential?> registerAccount({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(fullName);

      await userCredential.user?.reload();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration Failed';

      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email already registered';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password too weak';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }

      return null;
    }
  }

  static Future<UserCredential?> loginAccount({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login Failed';

      if (e.code == 'user-not-found') {
        errorMessage = 'User not found';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }

      return null;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
