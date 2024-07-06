import 'package:flutter_genesis_cli/src/commands/process/process.dart';
import 'package:flutter_genesis_cli/src/shared/logger.dart';
import 'package:flutter_genesis_cli/src/shared/validators.dart';
import 'package:uuid/uuid.dart';

import '../../../exceptions/firebase_exception.dart';

Future<(String, String)> getAppId({
  required String token,
  required String name,
  required bool Function(String) validator,
}) async {
  // return (appId['id']! as String, appId['name']! as String);
  // var appId = null;
  // TODO: solve FirebaseProjectNotFoundException error to create a new project
  m('Listing existing firebase projects');
  final appId = await _listProject(token, name);
  if (appId == null) {
    return _createAppId(token, name);
  } else {
    final projectId = appId['id']! as String;
    if (validator(projectId)) {
      return (projectId, appId['name']! as String);
    } else {
      e('$projectId already has a project with that package name. Please try again');
      return await getAppId(name: name, token: token, validator: validator);
    }
  }
}

Future<(String, String)> _createAppId(String token, String projectName) async {
  try {
    final name = process.getInput(
      prompt: 'Enter a project name for your new firebase project',
      defaultValue: projectName,
      validator: AppValidators.isFirebaseProjectIdValid,
    );
    String uniqueID = Uuid().v4();
    uniqueID = uniqueID.substring(0, 8);
    // final projectId = '${name}';
    final projectId = '${name + '-' + uniqueID}';
    await process.run('firebase',
        arguments: [
          'projects:create',
          '$projectId',
          '--display-name',
          '$name',
          '--token',
          '$token',
        ],
        showInlineResult: false,
        showSpinner: true,
        errorMessage: '',
        spinnerMessage: (done) =>
            done ? 'Created Firebase project' : 'Creating Firebase project ',
        onError: () =>
            throw FirebaseAppException('Firebase project creation failed'));

    m('Configuring Flutter with $projectId ($name)');

    await process.delayProcess(5, 'Waiting for Firebase Project Sync');

    return (projectId, name);
  } on FirebaseAppException catch (error) {
    e(error.message);
    return _createAppId(token, projectName);
  } on Exception catch (error) {
    e('Something went wrong ${error.toString()}');
    rethrow;
  }
}

List<Map<dynamic, dynamic>>? projectDetails;
Future<Map<dynamic, dynamic>?> _listProject(String token, String name) async {
  if (projectDetails == null) {
    final result = await process.run(
      'firebase',
      streamOutput: false,
      arguments: ['projects:list', '--token', '$token'],
      showInlineResult: false,
      showSpinner: true,
      spinnerMessage: (done) =>
          done ? 'Gotten Firebase projects' : 'Gathering Firebase projects',
    );
    projectDetails = _extractProjectDetails(result!.stdout);
  }

  final projectIndex = process.getSelectInput(
    prompt: 'Select a Firebase project to configure ${name} with',
    options: projectDetails!.map((e) => '${e['name']}(${e['id']})').toList()
      ..add('<create a new project>'),
  );

  if (projectIndex == projectDetails!.length) {
    return null;
  } else {
    m('Configuring Flutter with ${projectDetails![projectIndex]}');
    return projectDetails![projectIndex];
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
