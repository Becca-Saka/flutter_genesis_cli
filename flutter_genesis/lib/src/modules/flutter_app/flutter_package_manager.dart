import 'package:flutter_genesis/src/modules/flutter_app/flutter_cli.dart';
import 'package:flutter_genesis/src/shared/logger.dart';
import 'package:flutter_genesis/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';

class FlutterPackageManager {
  static Future<void> getPackages(FlutterAppDetails flutterAppDetails) async {
    m('Setting up external packages');
    final firebaseAppDetails = flutterAppDetails.firebaseAppDetails;
    final path = flutterAppDetails.path;
    if (firebaseAppDetails != null) {
      final authPackages =
          _getAuthCorePackages(firebaseAppDetails.authenticationMethods, path);

      if (authPackages.isNotEmpty) {
        await FlutterCli.pubAdd(authPackages, path);
      }
    }
  }

  static List<String> _getAuthCorePackages(
      List<AuthenticationMethod>? authMethod, String path) {
    List<String> authPackages = [];
    if (authMethod != null && authMethod.isNotEmpty) {
      if (authMethod.contains(AuthenticationMethod.google)) {
        authPackages.add('flutter_svg');
      }
    }
    return authPackages;
  }
}
