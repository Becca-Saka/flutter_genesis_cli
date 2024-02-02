import 'dart:io';

import 'package:cli_app/src/common/logger.dart';
import 'package:cli_app/src/common/process/process.dart';

class FlutterCli {
  FlutterCli._();
  static FlutterCli get instance => FlutterCli._();
  static late String appPath;
  AdireCliProcess process = AdireCliProcess();

  Future<void> pubRun(List<String> args, String workingDirectory) async {
    logger.i('Running dependencies $process');
    await process.processRun(
      'flutter',
      arguments: ['pub', 'run', ...args],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    logger.i('Flutter pub run done');
  }

  Future<void> pubAdd(List<String> packages, String workingDirectory) async {
    logger.i('Adding dependencies $packages');
    await process.processRun(
      'flutter',
      arguments: ['pub', 'add', ...packages],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    logger.i('Flutter pub get done');
  }

  Future<void> pubGet(String workingDirectory) async {
    logger.i('Getting dependencies');
    await process.processRun(
      'flutter',
      arguments: [
        'pub',
        'get',
      ],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    logger.i('Flutter pub get done');
  }

  Future<void> activate(String packageName, String workingDirectory) async {
    logger.i('Activating $packageName');
    await process.processRun(
      'dart',
      arguments: ['pub', 'global', 'activate', packageName],
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    logger.i('Activated $packageName');
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
