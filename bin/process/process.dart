import 'dart:io';

import '../logger/logger.dart';

//TODO: add timeout and retry for network errors
Future<void> processRun(
  String executable, {
  List<String>? arguments,
  String? workingDirectory,
  Map<String, String>? environment,
  bool runInShell = true,
}) async {
  final dirResult = await Process.run(
    executable,
    arguments ?? [],
    workingDirectory: workingDirectory,
    runInShell: runInShell,
    environment: environment,
  );
  catchError(dirResult);
}

void catchError(ProcessResult results) {
  if (results.exitCode != 0) {
    logger.e('${results.stderr}');
    logger.e('EXIT CODE ${results.exitCode}');
    exit(1);
  }
}
