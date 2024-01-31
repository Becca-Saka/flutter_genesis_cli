import '../logger/logger.dart';
import '../process/process.dart';

class FlutterCli {
  FlutterCli._();
  static FlutterCli get instance => FlutterCli._();
  static late String appPath;

  // Future<String> create(String name, String appPath) async {
  //   //TODO: check if flutter and dart installed
  //   logger.i('Creating flutter project $name in $appPath');
  //   final String projectPath = '$appPath/generated/$name';
  //   await processRun(
  //     'flutter',
  //     arguments: [
  //       'create',
  //       '--project-name',
  //       name,
  //       projectPath,
  //     ],
  //     workingDirectory: appPath,
  //     runInShell: true,
  //   );
  //   logger.i('Flutter create done');
  //   logger.i('Awesome $name is created in $projectPath');
  //   FlutterCli.appPath = projectPath;
  //   return projectPath;
  // }

  Future<void> pubRun(List<String> process, String workingDirectory) async {
    logger.i('Running dependencies $process');
    await processRun(
      'flutter',
      arguments: ['pub', 'run', ...process],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    logger.i('Flutter pub run done');
  }

  Future<void> pubAdd(List<String> packages, String workingDirectory) async {
    logger.i('Adding dependencies $packages');
    await processRun(
      'flutter',
      arguments: ['pub', 'add', ...packages],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    logger.i('Flutter pub get done');
  }

  Future<void> pubGet(String workingDirectory) async {
    logger.i('Getting dependencies');
    await processRun(
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
    await processRun(
      'dart',
      arguments: ['pub', 'global', 'activate', packageName],
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    logger.i('Activated $packageName');
  }
}
