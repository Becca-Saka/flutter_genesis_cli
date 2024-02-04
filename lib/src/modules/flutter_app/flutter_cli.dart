import 'dart:io';

import 'package:cli_app/src/common/logger.dart';
import 'package:cli_app/src/common/process/process.dart';

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
  FlutterCli._();
  static FlutterCli get instance => FlutterCli._();
  static late String appPath;
  AdireCliProcess process = AdireCliProcess();

  Future<void> pubRun(List<String> args, String workingDirectory) async {
    m('Running dependencies $process');
    await process.processRun(
      'flutter',
      arguments: ['pub', 'run', ...args],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    m('Flutter pub run done');
  }

  Future<void> pubAdd(List<String> packages, String workingDirectory) async {
    m('Adding dependencies $packages');
    await process.processRun(
      'flutter',
      arguments: ['pub', 'add', ...packages],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    m('Flutter pub get done');
  }

  Future<void> pubGet(String workingDirectory) async {
    m('Getting dependencies');
    await process.processRun(
      'flutter',
      arguments: [
        'pub',
        'get',
      ],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    m('Flutter pub get done');
  }

  Future<void> activate(String packageName, String workingDirectory) async {
    m('Activating $packageName');
    await process.processRun(
      'dart',
      arguments: ['pub', 'global', 'activate', packageName],
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    m('Activated $packageName');
  }

  void clearProcess() {
    if (Platform.isWindows) {
      // TODO: not tested
      print(Process.runSync("cls", [], runInShell: true).stdout);
    } else {
      print(Process.runSync("clear", [], runInShell: true).stdout);
    }
  }
}
