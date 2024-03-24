import 'package:interact/interact.dart';

class AppValidators {
  static bool isFirebaseProjectIdValid(String? projectId) {
    // Firebase project IDs must be lowercase and contain only alphanumeric and dash characters

    final RegExp validProjectIdRegex = RegExp(r'^[a-z0-9\-]+$');
    if (projectId == null || projectId.isEmpty) {
      throw ValidationError('Firebase project id cannot be empty');
    } else if (!validProjectIdRegex.hasMatch(projectId)) {
      throw ValidationError(
          'Firebase proiect ids must be lowercase and contain only alphanumeric and dash characters.');
    }
    return true;
  }

  static bool isValidFlutterPackageName(String packageName) {
    // Check if the package name follows the specified format
    RegExp validPackagePattern =
        RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$');
    if (!validPackagePattern.hasMatch(packageName)) {
      throw ValidationError(
          '$packageName is not a valid package name. Please enter a valid package name.');
    }
    return true;
  }

  static bool checkValidAppIconPath(String? value) {
    if (value == null || value.isEmpty) {
      throw ValidationError('App icon path must not be empty');
    }
    if (!value.endsWith('.png')) {
      throw ValidationError('App icon path must point to a .png file');
    }

    return true;
  }

  static bool notNullAndNotEmpty(String? value,
      {String message = 'Value cannot be null or empty'}) {
    if (value == null || value.isEmpty) {
      throw ValidationError(message);
    }

    return true;
  }
}
