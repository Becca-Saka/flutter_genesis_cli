import 'package:flutter_genesis/src/commands/process/process.dart';
import 'package:flutter_genesis/src/shared/logger.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';

///
/// This class provides methods to run common Flutter CLI commands such as
/// 'pub run', 'pub add', 'pub get', and activating global packages.
///
///
/// Dependencies:
/// - 'cli_app/src/common/logger.dart': Logger class for logging messages.
/// - 'cli_app/src/common/process/process.dart': AdireCliProcess class for handling processes.
///
/// Example:
/// ```dart
/// FlutterCli flutterCli = FlutterCli.instance;
/// flutterCli.pubRun(['build'], '/path/to/project');
/// flutterCli.pubAdd(['provider', 'http'], '/path/to/project');
/// flutterCli.pubGet('/path/to/project');
/// flutterCli.activate('dartdoc', '/path/to/project');
/// ```
class FlutterCli {
  static late String appPath;
  static FlutterGenesisCli process = FlutterGenesisCli();

  static Future<void> create(
      {required FlutterAppDetails flutterAppDetails}) async {
    await process.run(
      'flutter',
      arguments: [
        'create',
        '--org',
        '${flutterAppDetails.packageName}',
        '--platforms=${flutterAppDetails.platforms.map((e) => e.name).toList().join(',')}',
        flutterAppDetails.name
      ],
      workingDirectory: flutterAppDetails.path,
      runInShell: true,
    );
  }

  static Future<void> pubRun(List<String> args, String workingDirectory,
      [bool? runInShell]) async {
    m('Running dependencies $args on $workingDirectory');
    await process.run(
      'dart',
      streamOutput: false,
      arguments: ['pub', 'run', ...args],
      workingDirectory: workingDirectory,
      runInShell: runInShell ?? true,
    );
    m('Flutter pub run done');
  }

  static Future<void> pubAdd(List<String> packages, String workingDirectory,
      {bool isDev = false}) async {
    m('Adding dependencies $packages');
    List<String> addCommand = ['add'];
    if (isDev) {
      addCommand.add('-d');
    }
    await process.run(
      'dart',
      streamOutput: false,
      arguments: ['pub', ...addCommand, ...packages],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    m('Flutter pub get done');
  }

  // static Future<void> pubGet(String workingDirectory) async {
  //   m('Getting dependencies');
  //   await process.run(
  //     'flutter',
  //     streamInput: false,
  //     arguments: [
  //       'pub',
  //       'get',
  //     ],
  //     workingDirectory: workingDirectory,
  //     runInShell: true,
  //   );
  //   m('Flutter pub get done');
  // }

  static Future<void> format(String workingDirectory) async {
    m('Running Dart Format');
    await process.run(
      'dart',
      streamOutput: false,
      arguments: ['format', '.'],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    m('Dart Format done');
  }

  static Future<void> activate(
      String packageName, String workingDirectory) async {
    m('Activating $packageName');
    await process.run(
      'dart',
      streamOutput: false,
      arguments: ['pub', 'global', 'activate', packageName],
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    m('Activated $packageName');
  }
}
