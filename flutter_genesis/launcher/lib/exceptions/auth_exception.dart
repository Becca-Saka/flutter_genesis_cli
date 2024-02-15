import 'package:flutter/material.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthExceptionHandler {
  static handleFirebaseAuthException(e) {
    debugPrint(e.code);
    String status;
    switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        status = "Your email address appears to be malformed.";
        break;
      case "ERROR_WRONG_PASSWORD":
        status = "Your password is wrong.";
        break;
      case "ERROR_USER_NOT_FOUND":
        status = "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        status = "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        status = "Too many requests. Try again later.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        status = "Signing in with Email and Password is not enabled.";
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case 'email-already-in-use':
        status =
            "The email has already been registered. Please login or reset your password.";
        break;
      default:
        status = "An undefined Error happened.";
    }
    return status;
  }
}
