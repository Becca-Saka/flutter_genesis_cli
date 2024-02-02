import 'dart:async';
import 'dart:io';

import 'package:interact/interact.dart';

import '../logger.dart';

///This is a wrapper around [Interact] and [Process] for
///interacting with the CLI.
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

  int getSelectInput({
    required String prompt,
    required List<String> options,
    String? defaultValue,
  }) {
    return Select(
      prompt: prompt,
      options: options,
    ).interact();
  }

  List<int> getMultiSelectInput({
    required String prompt,
    required List<String> options,
    List<String>? defaultValue,
  }) {
    return MultiSelect(
      prompt: prompt,
      options: options,
      defaults: options.map((e) => defaultValue?.contains(e) ?? false).toList(),
    ).interact();
  }

//TODO: add timeout and retry for network errors
  Future<ProcessResult> processRun(
    String executable, {
    List<String>? arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = true,
    bool showInlineResult = true,
    bool showSpinner = false,
    String Function(bool)? spinnerMessage,
  }) async {
    SpinnerState? gift;
    if (showSpinner) {
      gift = Spinner(
        icon: '🏆',
        leftPrompt: (done) => '',
        rightPrompt: (done) {
          if (spinnerMessage != null) {
            return spinnerMessage(done);
          }
          return done ? 'Magic is done' : 'waiting for the magic to happen';
        },
      ).interact();
    }

    final dirResult = await Process.run(
      executable,
      arguments ?? [],
      workingDirectory: workingDirectory,
      runInShell: runInShell,
      environment: environment,
    );
    gift?.done();
    catchError(dirResult);
    if (showInlineResult) {
      m('${dirResult.stdout}');
    }
    return dirResult;
  }

  void catchError(ProcessResult results) {
    if (results.exitCode != 0) {
      e('${results.stderr}');
      e('${results.stdout}');
      e('EXIT CODE ${results.exitCode}');
      exit(1);
    }
  }
}
