import 'package:cli_app/src/common/logger.dart';
import 'package:cli_app/src/models/flutter_app_details.dart';
import 'package:cli_app/src/modules/flutter_app/flutter_app.dart';
import 'package:cli_app/src/modules/flutter_app/flutter_cli.dart';
import 'package:cli_app/src/modules/mason/mason_cli.dart';
import 'package:cli_app/src/templates/domain/firebase/flutter_fire_cli.dart';

Future<void> createApp() async {
  try {
    FlutterAppDetails flutterAppDetails = await FlutterApp.instance.init();

    final projectPath = await MasonCli.instance.init(flutterAppDetails);
    flutterAppDetails = flutterAppDetails.copyWith(path: projectPath);
    await FlutterCli.instance.pubGet(projectPath);
    // await FlutterApp.instance.updateAppDetails(flutterAppDetails, projectPath);
    await FlutterFireCli.instance.initializeFirebase(flutterAppDetails);
  } on Exception catch (ed) {
    e('Error: $ed');
  }
}
