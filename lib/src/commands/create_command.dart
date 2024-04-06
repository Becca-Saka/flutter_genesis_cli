import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flutter_genesis_cli/src/modules/flutter_app/flutter_app.dart';

class CreateApp extends Command {
  @override
  String get description => 'Create a new Flutter app';

  @override
  String get name => 'create';

  @override
  ArgParser get argParser {
    return ArgParser()
      ..addOption(
        'name',
        abbr: 'n',
        help: 'The name of the app to create.',
      )
      ..addOption(
        'org',
        abbr: 'o',
        help: 'The organization to use for the app.',
        valueHelp: 'com.example',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'The path to create the app.',
        valueHelp: Directory.current.path + 'examples/',
      )
      ..addOption(
        'flavor',
        abbr: 'f',
        help: 'Whether the app should be created with a flavor.',
      );
  }

  @override
  Future<void> run() async {
    final appName = argResults?['name'] as String?;
    final orgName = argResults?['org'] as String?;
    final path = argResults?['path'] as String?;
    final flavor = argResults?['flavor'] as String?;

    FlutterApp app = FlutterApp();
    final flutterAppDetails = await app.init(
      name: appName,
      package: orgName,
      path: path,
      flavor: flavor,
    );
    await app.postCreate(flutterAppDetails);
    // print('Creating app $appName with org $orgName and flavor $flavor');
    // final paas = argResults?['paas'] as String?;
    // final analytics = argResults?['analytics'] as String?;
    // final subscriptions = argResults?['subs'] as bool;

    // FlutterApp app = FlutterApp();
    // final flutterAppDetails = await app.init();
    // await app.postCreate(flutterAppDetails);
  }
}
