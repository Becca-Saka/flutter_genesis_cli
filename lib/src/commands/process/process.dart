import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:interact/interact.dart';
import 'package:tint/tint.dart';

import '../../shared/logger.dart';

///This is a wrapper around [Interact] and [Process] for
///interacting with the CLI.
///
///The Interact class is used to get interactive input from the user.
///it provides the [Input], [Select], and [MultiSelect] classes.
///

final FlutterGenesisCli process = FlutterGenesisCli();

class FlutterGenesisCli {
  String getInput({
    required String prompt,
    bool Function(String)? validator,
    String? initialText,
    String? defaultValue,
  }) {
    try {
      String promptBold = prompt.bold();

      String questionMark = '? '.yellow();
      String checkMark = '✔ '.green();
      String forwardMark = ' › '.grey();
      String seperator = ' · '.grey();
      String text = questionMark + promptBold;
      if (defaultValue != null) {
        text += ' (${defaultValue})'.grey();
      }
      if (initialText != null) {
        text += ' ' + initialText;
      }

      stdout.write(text + forwardMark);

      stdin.echoMode = true;

      String? input = stdin.readLineSync();
      if (input == null || input.isEmpty) {
        input = defaultValue ?? initialText;
      }
      if (validator != null) {
        while (!validator(input ?? '')) {
          input = stdin.readLineSync();
        }
      }
      stdout.write('\x1B[1A\x1B[2K');
      stdout.writeln(
          checkMark + promptBold + seperator + '${input ?? ''}'.green());

      return input ?? '';
    } on ValidationError catch (err) {
      e(err.message);
      return getInput(
        prompt: prompt,
        validator: validator,
        initialText: initialText,
        defaultValue: defaultValue,
      );
    }
  }

  // String getInput({
  //   required String prompt,
  //   bool Function(String)? validator,
  //   String initialText = '',
  //   String? defaultValue,
  // }) {
  //   return Input(
  //     prompt: prompt,
  //     defaultValue: defaultValue,
  //     initialText: initialText,
  //     validator: validator,
  //   ).interact();
  // }

  bool getConfirmation({
    required String prompt,
    bool? defaultValue,
    bool waitForNewLine = false,
  }) {
    return Confirm(
      prompt: prompt,
      defaultValue: defaultValue,
      waitForNewLine: waitForNewLine,
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

  Future<ProcessResult?> run(
    String executable, {
    bool streamOutput = true,
    List<String>? arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = true,
    bool showInlineResult = true,
    bool catchErrorInline = true,
    bool showSpinner = false,
    String Function(bool)? spinnerMessage,
    String? errorMessage,
    Function? onError,
  }) async {
    SpinnerState? gift;
    bool hasError = false;
    if (showSpinner) {
      gift = Spinner(
        icon: '🏆',
        leftPrompt: (done) => '',
        rightPrompt: (done) {
          if (hasError && errorMessage != null) {
            return errorMessage;
          }

          if (spinnerMessage != null) {
            return spinnerMessage(done);
          }

          return done ? 'Magic is done' : 'Waiting for the magic to happen';
        },
      ).interact();
    }
    if (streamOutput) {
      await _processStart(
        executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        runInShell: runInShell,
        onError: () {
          hasError = true;
          gift?.done();
          if (onError != null) {
            return onError();
          }
        },
        onDone: () => gift?.done(),
      );
      return null;
    } else {
      return await _processRun(
        executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        runInShell: runInShell,
        showInlineResult: showInlineResult,
        onDone: () => gift?.done(),
      );
    }
  }

  Future<void> _processStart(
    String executable, {
    List<String>? arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = true,
    Function? onError,
    Function? onDone,
  }) async {
    final dirResult = await Process.start(
      executable,
      arguments ?? [],
      workingDirectory: workingDirectory,
      runInShell: runInShell,
      environment: environment,
    );
    transFormOutput(dirResult.stdout);
    transFormOutput(dirResult.stderr);

    var exitCode = await dirResult.exitCode;

    if (exitCode != 0) {
      onError?.call();

      e('EXIT CODE ${exitCode}');
      reset();
      exit(1);
    } else {
      onDone?.call();
    }
  }

  Future<ProcessResult> _processRun(
    String executable, {
    List<String>? arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = true,
    bool showInlineResult = true,
    bool catchErrorInline = true,
    Function? onDone,
  }) async {
    final dirResult = await Process.run(
      executable,
      arguments ?? [],
      workingDirectory: workingDirectory,
      runInShell: runInShell,
      environment: environment,
    );
    onDone?.call();
    if (catchErrorInline) {
      catchError(dirResult);
    }
    if (showInlineResult) {
      m('${dirResult.stdout}');
    }
    return dirResult;
  }

  Future<void> delayProcess(int duration, String processName) async {
    SpinnerState gift = Spinner(
      icon: '🏆',
      leftPrompt: (done) => '',
      rightPrompt: (done) {
        return done ? 'Magic is done' : '$processName';
      },
    ).interact();
    await Future.delayed(Duration(seconds: duration));

    gift.done();
  }

  void transFormOutput(Stream<List<int>> stream) {
    stream.transform(utf8.decoder).listen((String data) {
      m('$data');
    });
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
