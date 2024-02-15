import 'package:cli_app/src/common/logger.dart';
import 'package:cli_app/src/models/flutter_app_details.dart';
import 'package:cli_app/src/modules/flutter_app/flutter_app.dart';
import 'package:cli_app/src/modules/generators/structure/structure_generator.dart';
import 'package:cli_app/src/templates/domain/firebase/flutter_fire_cli.dart';

Future<void> createApp() async {
  try {
    // AdireCliProcess()
    //     .processStart('flutter', arguments: ['pub', 'add', 'firebase_core']);
    FlutterAppDetails flutterAppDetails = await FlutterApp.instance.init();
    // final projectPath = await MasonCli.instance.init(flutterAppDetails);
    // flutterAppDetails = flutterAppDetails.copyWith(path: projectPath);
    // await FlutterCli.instance.pubGet(projectPath);
    if (flutterAppDetails.firebaseAppDetails != null) {
      await FlutterFireCli.instance.initializeFirebase(flutterAppDetails);
    }
    // await FlutterPackageManager.getPackages(flutterAppDetails);
    StructureGenerator.instance.generateStructure(flutterAppDetails.name);
    // await FlutterPackageManager.getPackages(flutterAppDetails);
  } on Exception catch (ed) {
    e('Error: $ed');
  }
}
