import 'package:cli_app/src/common/logger.dart';
import 'package:cli_app/src/models/flutter_app_details.dart';
import 'package:cli_app/src/modules/flutter_app/flutter_app.dart';
import 'package:cli_app/src/modules/flutter_app/flutter_cli.dart';
import 'package:cli_app/src/modules/mason/mason_cli.dart';
import 'package:cli_app/src/templates/firebase_template/flutter_fire_cli.dart';

Future<void> createApp() async {
  try {
    // await FlutterFireCli.instance.getAppId(token);
    FlutterAppDetails flutterAppDetails = await FlutterApp.instance.init();
    // logger.i(flutterAppDetails);

    final projectPath = await MasonCli.instance.init(flutterAppDetails);
    flutterAppDetails = flutterAppDetails.copyWith(path: projectPath);
    await FlutterCli.instance.pubGet(projectPath);
    // await FlutterApp.instance.updateAppDetails(flutterAppDetails, projectPath);
    await FlutterFireCli.instance.initializeFirebase(flutterAppDetails);
    // await FlutterApp.instance.updateAppDetails(
    //     FlutterAppDetails(
    //         name: 'onethewoman',
    //         packageName: 'com.adireapp.onethewoman',
    //         path:
    //             '/Users/becca/StudioProjects/flutter/Work/Adire/cli_app/opry'),
    //     '/Users/becca/StudioProjects/flutter/Work/Adire/cli_app/opry');
  } on Exception catch (e) {
    logger.e('Error: $e');
  }
}
