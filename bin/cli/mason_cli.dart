import 'dart:convert';
import 'dart:io';

import '../cli_app.dart';
import '../logger/logger.dart';
import '../process/process.dart';

class MasonCli {
  MasonCli._();
  static MasonCli get instance => MasonCli._();
  late String name;
  late String appPath;
  late String projectPath;
  late String masonPath;

  Future<void> init() async {
    masonPath = Directory.current.path;
    logger.i('intializing mason project in $masonPath');
    // await _createMasonDirectory();
    // await _activateMason();
    // await _initMason();
    await _makeProject();
    // await _addMasonBlock();
    logger.i('intialized mason project in $masonPath');
  }

  Future<void> _makeProject() async {
    // mason add conference_app_toolkit --path ../conference_app_toolkit
    logger.d('What should we call your project?');
    final name = getAppName();
    await processRun(
      'mkdir',
      arguments: ['$name'],
      workingDirectory: masonPath,
      runInShell: true,
    );
    final projectPath = '$masonPath/$name';
    await processRun(
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

    // Convert data to JSON
    final data = {
      'name': name,
      'app_domain': 'com.example.$name',
    };
    final jsonString = jsonEncode(data);
    final jsonPath = '$projectPath/config.json';
    // Open file for writing
    final file = File(jsonPath);
    await file.writeAsString(jsonString);
// file.
    // Close the file
    // await file();

    print('JSON file saved successfully to: $jsonPath');
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
    await processRun(
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

  // Future<void> init(String name, String appPath, String projectPath) async {
  //   this.name = name;
  //   this.appPath = appPath;
  //   this.projectPath = projectPath;
  //   logger.i('intializing mason project $name in $projectPath');
  //   // await _createMasonDirectory();
  //   await _activateMason();
  //   await _initMason();
  //   // await _addMasonBlock();
  //   logger.i('intialized mason project in $masonPath');
  // }

  Future<void> _createMasonDirectory() async {
    await processRun(
      'mkdir',
      arguments: ['.mason-$name'],
      workingDirectory: projectPath,
      runInShell: true,
    );
    masonPath = '$appPath/generated/$name/.mason-$name';
  }

  Future<void> _activateMason() async {
    await processRun(
      'dart',
      arguments: ['pub', 'global', 'activate', 'mason_cli'],
      workingDirectory: masonPath,
      runInShell: true,
    );
  }

  Future<void> _initMason() async {
    await processRun(
      'mason',
      arguments: ['init'],
      workingDirectory: masonPath,
      runInShell: true,
    );
  }

  Future<void> _addMasonBlock() async {
    await processRun(
      'mason',
      arguments: ['new', '${name}_cli'],
      workingDirectory: masonPath,
      runInShell: true,
    );
  }
  // rm myfile
}
