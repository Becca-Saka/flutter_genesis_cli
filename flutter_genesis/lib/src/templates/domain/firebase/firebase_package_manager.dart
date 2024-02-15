import 'package:flutter_genesis/src/common/logger.dart';
import 'package:flutter_genesis/src/models/firebase_app_details.dart';
import 'package:flutter_genesis/src/models/flutter_app_details.dart';
import 'package:flutter_genesis/src/modules/flutter_app/flutter_cli.dart';

class FirebasePackageManager {
  static void getPackages(FlutterAppDetails flutterAppDetails) {
    m('Setting up firebase packages');
    final firebaseAppDetails = flutterAppDetails.firebaseAppDetails!;
    final path = flutterAppDetails.path;
    final corePackages =
        _getCorePackages(firebaseAppDetails.selectedOptions, path);
    final authPackages =
        _getAuthCorePackages(firebaseAppDetails.authenticationMethods, path);

    FlutterCli.instance.pubAdd(corePackages + authPackages, path);
  }

  static List<String> _getCorePackages(
      List<FirebaseOptions> selectedOptions, String path) {
    List<String> firebasePackages = [];
    if (selectedOptions.isNotEmpty) {
      selectedOptions.add(FirebaseOptions.core);
      //TODO: if auth is selected and cloud firestore is not selected
      m('Adding core packages for selected firebase options');
      for (var option in selectedOptions) {
        if (firebasePackagesMap.containsKey(option)) {
          firebasePackages.add(firebasePackagesMap[option]!);
        }
      }
    } else {
      m('No options selected, skipping');
    }
    return firebasePackages;
  }

  static List<String> _getAuthCorePackages(
      List<AuthenticationMethod>? authMethod, String path) {
    List<String> authPackages = [];
    if (authMethod != null && authMethod.isNotEmpty) {
      m('Adding auth packages for selected auth options');

      for (var option in authMethod) {
        if (option == AuthenticationMethod.google) {
          authPackages.add('flutter_svg');
        }
        if (authPackagesMap.containsKey(option)) {
          authPackages.add(authPackagesMap[option]!);
        }
      }
    } else {
      m('No auth options selected, skipping');
    }
    return authPackages;
  }
}
