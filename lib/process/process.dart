import 'dart:io';

import 'package:interact/interact.dart';

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

class AdireCliProcess {
  String getInput({
    required String prompt,
    bool Function(String)? validator,
    String initialText = '',
    String? defaultValue,
  }) {
    return Input(
      prompt: prompt,
      defaultValue: defaultValue,
      initialText: initialText,
      validator: validator,
    ).interact();
  }
}
