import 'dart:io';

import 'cli/mason_cli.dart';
import 'logger/logger.dart';

const String version = '0.0.1';

Future<void> main() async {
  try {
    // String name = _getAppName();
    // String appPath = _getPath();
    // final projectPath = await FlutterCli.instance.create(name, appPath);

    await MasonCli.instance.init();
    // await MasonCli.instance.init(name, appPath, projectPath);
    // await FlutterCli.instance.pubGet(['firebase_core', 'cloud_firestore']);
    // final projectPath = '${Directory.current.path}generated/adire';
    // await FlutterFireCli.instance.init(projectPath);
  } on Exception catch (e) {
    logger.e('Error: $e');
  }
}

String getAppName() {
  print('What Should We call your project?');
  String? name = stdin.readLineSync();
  if (name == null || name.isEmpty) {
    throw Exception('Name cannot be empty');
  }
  //to lower case

  name = name.toLowerCase();
  //replace space with underscore
  name = name.replaceAll(' ', '_');
  return name;
}

String _getPath() {
  // print('Where is your project located?(press enter to use current path)');
  // String? path = stdin.readLineSync();
  // if (path == null || path.isEmpty) {
  return Directory.current.path;
  // } else {
  //   return path;
  // }
}
