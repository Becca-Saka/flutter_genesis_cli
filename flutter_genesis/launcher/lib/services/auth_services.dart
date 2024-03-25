// START REMOVE BLOCK: firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// END REMOVE BLOCK: firestore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// START REMOVE BLOCK: googleAuth
import 'package:google_sign_in/google_sign_in.dart';
// END REMOVE BLOCK: googleAuth
import 'package:launcher/exceptions/auth_exception.dart';
import 'package:launcher/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
// START REMOVE BLOCK: firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// END REMOVE BLOCK: firestore

// START REMOVE BLOCK: googleAuth
  final _googleSignIn = GoogleSignIn(scopes: ['email']);
// END REMOVE BLOCK: googleAuth

  Future<bool> createAccount(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      throw AuthException(message);
    } on Exception catch (e, s) {
      debugPrint('$e\n$s');
      rethrow;
    }
  }

// START REMOVE BLOCK: firestore
  Future<bool> saveUserDetails({
    required String uid,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
      });

      return true;
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      throw AuthException(message);
    } on Exception catch (e, s) {
      debugPrint('$e\n$s');
      rethrow;
    }
  }

// END REMOVE BLOCK: firestore

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      debugPrint('$message');
      throw AuthException(message);
    } on Exception catch (e) {
      debugPrint('$e');
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;

// START REMOVE BLOCK: firestore
  Future<UserModel> getCurrentUserData(String email, String password) async {
    try {
      final response = await _firestore.doc(_auth.currentUser!.uid).get();
      if (response.data() != null) {
        return UserModel.fromMap(response.data()!);
      }
      throw AuthException('User not found');
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      throw AuthException(message);
    } on Exception catch (e, s) {
      debugPrint('$e\n$s');
      rethrow;
    }
  }
// END REMOVE BLOCK: firestore

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      debugPrint('$message');
      throw AuthException(message);
    } on Exception catch (e, s) {
      debugPrint('$e\n$s');
      rethrow;
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return true;
      }

      throw AuthException('User not found');
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      debugPrint('$message');
      throw AuthException(message);
    } on Exception catch (e, s) {
      debugPrint('$e\n$s');
      rethrow;
    }
  }

// START REMOVE BLOCK: googleAuth

  Future<bool> logInWithGoogleUser() async {
    try {
      await signOut();
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount != null) {
        final auth = await googleAccount.authentication;
        final googleAuthAccessToken = auth.accessToken;
        final authCredential = GoogleAuthProvider.credential(
            accessToken: googleAuthAccessToken, idToken: auth.idToken);
        await FirebaseAuth.instance.signInWithCredential(authCredential);
        return true;
      }
      throw AuthException('Error signing in with Google');
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      debugPrint('$message');
      throw AuthException(message);
    } on Exception catch (e, s) {
      debugPrint('$e\n$s');
      rethrow;
    }
  }

// END REMOVE BLOCK: googleAuth

  Future<void> signOut() async {
    await _auth.signOut();
    // START REMOVE BLOCK: googleAuth
    await _googleSignIn.signOut();
    // END REMOVE BLOCK: googleAuth
  }
}
