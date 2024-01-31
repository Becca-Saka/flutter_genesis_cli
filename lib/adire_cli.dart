import 'package:cli_app/cli/flutter_app.dart';
import 'package:cli_app/cli/flutter_cli.dart';
import 'package:cli_app/cli/flutter_fire.dart';
import 'package:cli_app/cli/mason_cli.dart';
import 'package:cli_app/logger/logger.dart';

Future<void> createApp() async {
  try {
    final flutterAppDetails = FlutterApp.instance.init();

    final projectPath = await MasonCli.instance.init(flutterAppDetails);
    await FlutterCli.instance.pubGet(projectPath);
    await FlutterApp.instance.updateAppDetails(flutterAppDetails, projectPath);
    await FlutterFireCli.instance.init(projectPath);
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
