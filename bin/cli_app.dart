import 'cli/flutter_app.dart';
import 'cli/flutter_cli.dart';
import 'cli/mason_cli.dart';
import 'logger/logger.dart';

const String version = '0.0.1';

Future<void> main() async {
  try {
    final flutterAppDetails = FlutterApp.instance.init();

    final projectPath = await MasonCli.instance.init(flutterAppDetails);
    await FlutterCli.instance.pubGet(projectPath);
    await FlutterApp.instance.updateAppDetails(flutterAppDetails, projectPath);
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
