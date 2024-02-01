import 'dart:io';

import 'package:cli_app/models/flutter_app_details.dart';
import 'package:cli_app/process/process.dart';
import 'package:cli_app/shared/validators.dart';
import 'package:flutterfire_cli/src/command_runner.dart';
import 'package:flutterfire_cli/src/flutter_app.dart';

import '../../cli/flutter_cli.dart';
import '../../logger/logger.dart';

class FlutterFireCli {
  FlutterFireCli._();
  static FlutterFireCli get instance => FlutterFireCli._();
  AdireCliProcess process = AdireCliProcess();

//TODO: use firebase CLI token to authenticate user in the gui app `firebase login:ci`
  Future<void> init(FlutterAppDetails flutterAppDetails) async {
    await FlutterCli.instance.activate(
      'flutterfire_cli',
      flutterAppDetails.path,
    );

    await _configure(flutterAppDetails);
    logger.i('FlutterFireCli init done');
  }

  Future<void> _configure(FlutterAppDetails flutterAppDetails) async {
    if (flutterAppDetails.firebaseAppDetails != null) {
      final dir = Directory(flutterAppDetails.path);
      logger.i('Configuring FlutterFire $dir $flutterAppDetails');

      await Process.run(
        'bash',
        [
          '-c',
          'export PATH="\$PATH":"<span class="math-inline">HOME/.pub-cache/bin" && dart pub global activate flutterfire_cli'
        ],
      );
      final app = await FlutterApp.load(dir);
      final flutterFire = FlutterFireCommandRunner(app);

      await flutterFire.run(['config']);
      await flutterFire.run([
        'config',
        '--project',
        '${flutterAppDetails.firebaseAppDetails?.firebaseProjectId}',
        '--platforms',
        'android,ios',
        '--token',
        '${flutterAppDetails.firebaseAppDetails?.cliToken}'
      ]);
      logger.i('Configuring done');
    } else {
      logger.i('Firebase project not defined, skipping');
    }
  }

  Future<String> getAppId(String token) async {
    final appId = await _listProject(token);

    if (appId == null) {
      return _createAppId();
    } else {
      return appId['id'];
    }
  }

  Future<String> _createAppId() async {
    return process.getInput(
      prompt: 'Enter a project id for your new firebase project',
      validator: AppValidators.isFirebaseProjectIdValid,
    );
  }

  Future<Map<dynamic, dynamic>?> _listProject(String token) async {
    final result = await process.processRun(
      'firebase',
      arguments: ['projects:list', '--token', '$token'],
      showInlineResult: false,
      showSpinner: true,
      spinnerMessage: (done) =>
          done ? 'Gotten Firebase projects' : 'Gathering Firebase projects',
    );

    final projectDetails = _extractProjectDetails(result.stdout);

    final projectIndex = process.getSelectInput(
      prompt:
          'Select a Firebase project to configure your Flutter application with',
      options: projectDetails.map((e) => '${e['name']}(${e['id']})').toList()
        ..add('<create a new project>'),
    );

    if (projectIndex == projectDetails.length) {
      return null;
    } else {
      return projectDetails[projectIndex];
    }
  }

  List<Map> _extractProjectDetails(String projectInfoText) {
    // Split the text into lines
    List<String> lines = projectInfoText.split('\n');

    // Extract project display names and project IDs
    List<String> projectDisplayNames = [];
    List<String> projectIds = [];
    List<Map> projectDetails = [];
    lines.removeAt(0);
    lines.removeAt(0);
    // logger.i('lines: $lines})');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('│')) {
        List<String> rowValues = lines[i]
            .split('│')
            .where((value) => value.trim().isNotEmpty)
            .map((value) => value.trim())
            .toList();

        if (rowValues.length >= 2) {
          projectDisplayNames.add(rowValues[0]);
          projectIds.add(rowValues[1]);
        }
      }
    }

    // Display the extracted information
    for (int i = 0; i < projectDisplayNames.length; i++) {
      projectDetails.add({
        'name': projectDisplayNames[i],
        'id': projectIds[i],
      });
    }
    projectDetails.removeWhere((element) =>
        element['id'] == 'Project ID' &&
        element['name'] == 'Project Display Name');
    return projectDetails;
  }
}
