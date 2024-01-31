import 'dart:io';

import 'package:flutterfire_cli/src/command_runner.dart';
import 'package:flutterfire_cli/src/flutter_app.dart';

import '../logger/logger.dart';
import 'flutter_cli.dart';

class FlutterFireCli {
  FlutterFireCli._();
  static FlutterFireCli get instance => FlutterFireCli._();

//TODO: use firebase CLI token to authenticate user in the gui app `firebase login:ci`
  Future<void> init(String appPath) async {
    // dart pub global activate flutterfire_cli
    await FlutterCli.instance.activate('flutterfire_cli', appPath);
    await _configure(appPath);
    logger.i('FlutterFireCli init done');
  }

  Future<void> _configure(String appPath) async {
    final dir = Directory(appPath);
    logger.i('Configuring FlutterFire $dir $appPath');
    await Process.run(
      'bash',
      [
        '-c',
        'export PATH="\$PATH":"<span class="math-inline">HOME/.pub-cache/bin" && dart pub global activate flutterfire_cli'
      ],
    );
    final app = await FlutterApp.load(dir);
    final flutterFire = FlutterFireCommandRunner(app);
    await flutterFire.run(['config']);

    logger.i('Configuring done');
  }
}
