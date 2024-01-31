import 'package:interact/interact.dart';

class AppValidators {
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

  static bool notNullAndNotEmpty(String? value,
      {String message = 'Value cannot be null or empty'}) {
    if (value == null || value.isEmpty) {
      throw ValidationError(message);
    }

    return true;
  }
}
