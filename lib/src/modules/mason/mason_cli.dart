import 'dart:convert';
import 'dart:io';

import 'package:cli_app/src/models/flutter_app_details.dart';

import '../../common/logger.dart';
import '../../common/process/process.dart';

class MasonCli {
  MasonCli._();
  static MasonCli get instance => MasonCli._();
  late String name;
  late String appPath;
  late String projectPath;
  late String masonPath;
  late FlutterAppDetails flutterAppDetails;
  final AdireCliProcess process = AdireCliProcess();
  Future<String> init(FlutterAppDetails flutterAppDetails) async {
    masonPath = flutterAppDetails.path;
    this.name = flutterAppDetails.name;
    this.flutterAppDetails = flutterAppDetails;
    logger.i('intializing mason project in $masonPath');
    await _initMason();
    await _makeProject();
    logger.i('intialized mason project in $masonPath');
    return projectPath;
  }

  Future<void> _initMason() async {
    await process.processRun(
      'mason',
      arguments: ['init'],
      workingDirectory: masonPath,
      runInShell: true,
    );
  }

  Future<void> _makeProject() async {
    projectPath = await _createProjectDirectory();
    await _masonAdd();

    final jsonPath = await _createConfigFile();

    // mason make conference_app_toolkit
    // await Process.start(
    //   'mason',
    //   [
    //     'make',
    //     'cli_app_brick',
    //     '-c',
    //     '$jsonPath',
    //   ],
    //   workingDirectory: projectPath,
    //   runInShell: true,
    // );
    await _masonMake(jsonPath);
  }

  Future<String> _createProjectDirectory() async {
    await process.processRun(
      'mkdir',
      arguments: ['$name'],
      workingDirectory: masonPath,
      runInShell: true,
    );
    return '$masonPath/$name';
  }

  Future<void> _masonAdd() async {
    await process.processRun(
      'mason',
      arguments: [
        'add',
        'cli_app_brick',
        '--path',
        '../cli_app_brick',
      ],
      workingDirectory: projectPath,
      runInShell: true,
    );
  }

  Future<String> _createConfigFile() async {
    final data = {
      'name': name,
      'app_domain': flutterAppDetails.packageName,
      'android':
          flutterAppDetails.platforms.contains(FlutterAppPlatform.android),
      'ios': flutterAppDetails.platforms.contains(FlutterAppPlatform.ios),
      'web': flutterAppDetails.platforms.contains(FlutterAppPlatform.web),
      'windows':
          flutterAppDetails.platforms.contains(FlutterAppPlatform.windows),
      'macos': flutterAppDetails.platforms.contains(FlutterAppPlatform.macos),
      'linux': flutterAppDetails.platforms.contains(FlutterAppPlatform.linux),
    };
    final jsonString = jsonEncode(data);
    final jsonPath = '$projectPath/config.json';
    // Open file for writing
    final file = File(jsonPath);
    await file.writeAsString(jsonString);

    print('JSON file saved successfully to: $jsonPath');
    return jsonPath;
  }

  Future<void> _masonMake(String jsonPath) async {
    await process.processRun(
      'mason',
      arguments: [
        'make',
        'cli_app_brick',
        '-c',
        '$jsonPath',
      ],
      workingDirectory: projectPath,
      runInShell: true,
    );
  }

  // rm myfile
}
