import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:{{name}}/exceptions/auth_exception.dart';
import 'package:{{name}}/models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  Future<bool> createAccount(String email, String password,
      [bool verify = true]) async {
    try {
      final user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('user: $user');
      if (user.user != null) {
        await _firestore.collection('users').doc(user.user!.uid).set({
          'uid': user.user!.uid,
          'email': email,
        });
        if (verify) {
          user.user?.sendEmailVerification();
        }
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      throw AuthException(message);
    } on Exception catch (e, s) {
      debugPrint('$e\n$s');
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password,
      [bool verify = true]) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('user: $user');
      final currentUser = user.user;
      if (currentUser != null) {
        if (verify && !currentUser.emailVerified) {
          await currentUser.sendEmailVerification();
          throw AuthException('Please verify your email first');
        }
        final data =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (data.data() != null) {
          return UserModel(
            uid: data.data()!['uid'],
            email: data.data()!['email'],
          );
        }
      }
      throw AuthException('User not found');
    } on FirebaseAuthException catch (e) {
      final message = AuthExceptionHandler.handleFirebaseAuthException(e);
      debugPrint('$message');
      throw AuthException(message);
    } on Exception catch (e) {
      debugPrint('$e');
      rethrow;
    }
  }

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

  Future<UserModel> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
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

  Future<UserModel> logInWithGoogleUser() async {
    signOut();
    final googleAccount = await _googleSignIn.signIn();
    if (googleAccount != null) {
      final auth = await googleAccount.authentication;
      final googleAuthAccessToken = auth.accessToken;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuthAccessToken,
        idToken: auth.idToken,
      );
      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(authCredential)
          .catchError((onError) {
        debugPrint('$onError');
        throw Exception('Error signing in with Google');
      });
      final firebaseAccessToken = userCredential.credential?.accessToken;
      if (firebaseAccessToken != null) {
        final data = await _firestore
            .collection('users')
            .where('uid', isEqualTo: userCredential.user?.uid)
            .get();
        if (data.docs.isNotEmpty) {
          return UserModel(
            uid: data.docs.first.data()['uid'],
            email: data.docs.first.data()['email'],
          );
        }
      } else {
        signOut();
        throw Exception('Error signing in with Google');
      }
    }
    throw AuthException('Error signing in with Google');
  }

  void signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
