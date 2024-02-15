import 'package:flutter_genesis/src/common/logger.dart';
import 'package:flutter_genesis/src/models/flutter_app_details.dart';
import 'package:flutter_genesis/src/modules/flutter_app/flutter_app.dart';
import 'package:flutter_genesis/src/modules/generators/structure/structure_generator.dart';
import 'package:flutter_genesis/src/templates/domain/firebase/flutter_fire_cli.dart';
// import 'package:flutter_genesis/src/templates/domain/firebase/flutter_fire_cli.dart';

Future<void> createApp() async {
  try {
    FlutterAppDetails flutterAppDetails = await FlutterApp.instance.init();
    // flutterAppDetails = flutterAppDetails.copyWith(path: projectPath);
    // await FlutterCli.instance.pubGet(projectPath);
    if (flutterAppDetails.firebaseAppDetails != null) {
      await FlutterFireCli.instance.initializeFirebase(flutterAppDetails);
    }
    // await FlutterPackageManager.getPackages(flutterAppDetails);
    StructureGenerator.instance.generateStructure(
        flutterAppDetails.name, flutterAppDetails.stateManager.name);
    // await FlutterPackageManager.getPackages(flutterAppDetails);
  } on Exception catch (ed) {
    e('Error: $ed');
  }
}
