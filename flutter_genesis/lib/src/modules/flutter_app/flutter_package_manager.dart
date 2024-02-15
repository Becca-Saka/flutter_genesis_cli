import 'package:cli_app/src/common/logger.dart';
import 'package:cli_app/src/models/firebase_app_details.dart';
import 'package:cli_app/src/models/flutter_app_details.dart';
import 'package:cli_app/src/modules/flutter_app/flutter_cli.dart';

class FlutterPackageManager {
  static Future<void> getPackages(FlutterAppDetails flutterAppDetails) async {
    m('Setting up external packages');
    final firebaseAppDetails = flutterAppDetails.firebaseAppDetails!;
    final path = flutterAppDetails.path;
    final authPackages =
        _getAuthCorePackages(firebaseAppDetails.authenticationMethods, path);

    if (authPackages.isNotEmpty) {
      await FlutterCli.instance.pubAdd(authPackages, path);
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
