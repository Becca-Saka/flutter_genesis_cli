import 'dart:convert';
import 'dart:io';

import '../logger/logger.dart';
import '../process/process.dart';

class MasonCli {
  MasonCli._();
  static MasonCli get instance => MasonCli._();
  late String name;
  late String appPath;
  late String projectPath;
  late String masonPath;

  Future<String> init(String name, String path) async {
    masonPath = path;
    this.name = name;
    logger.i('intializing mason project in $masonPath');
    // await _createMasonDirectory();
    // await _activateMason();
    await _initMason();
    await _makeProject();
    // await _addMasonBlock();
    logger.i('intialized mason project in $masonPath');
    return projectPath;
  }

  Future<void> _initMason() async {
    await processRun(
      'mason',
      arguments: ['init'],
      workingDirectory: masonPath,
      runInShell: true,
    );
  }

//   Future<void> _makeProject() async {
//     projectPath = await _createProjectDirectory();
//     await processRun(
//       'mason',
//       arguments: [
//         'add',
//         'cli_app_brick',
//         '--path',
//         '../cli_app_brick',
//       ],
//       workingDirectory: projectPath,
//       runInShell: true,
//     );

//     // Convert data to JSON
//     final data = {
//       'name': name,
//       'app_domain': 'com.example.$name',
//     };
//     final jsonString = jsonEncode(data);
//     final jsonPath = '$projectPath/config.json';
//     // Open file for writing
//     final file = File(jsonPath);
//     await file.writeAsString(jsonString);
// // file.
//     // Close the file
//     // await file();

//     print('JSON file saved successfully to: $jsonPath');
//     // mason make conference_app_toolkit
//     // await Process.start(
//     //   'mason',
//     //   [
//     //     'make',
//     //     'cli_app_brick',
//     //     '-c',
//     //     '$jsonPath',
//     //   ],
//     //   workingDirectory: projectPath,
//     //   runInShell: true,
//     // );
//     await processRun(
//       'mason',
//       arguments: [
//         'make',
//         'cli_app_brick',
//         '-c',
//         '$jsonPath',
//       ],
//       workingDirectory: projectPath,
//       runInShell: true,
//     );
//     await processRun(
//       'flutter',
//       arguments: [
//         'packages',
//         'get',
//       ],
//       workingDirectory: projectPath,
//       runInShell: true,
//     );
//   }
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
    await processRun(
      'mkdir',
      arguments: ['$name'],
      workingDirectory: masonPath,
      runInShell: true,
    );
    return '$masonPath/$name';
  }

  Future<void> _masonAdd() async {
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
  }

  Future<String> _createConfigFile() async {
    final data = {
      'name': name,
      'app_domain': 'com.example.$name',
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
