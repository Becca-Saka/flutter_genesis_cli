import 'dart:io';

import 'package:cli_app/src/common/extensions/lists.dart';
import 'package:cli_app/src/common/logger.dart';
import 'package:cli_app/src/common/process/http_procress.dart';
import 'package:cli_app/src/common/process/process.dart';
import 'package:cli_app/src/common/validators.dart';
import 'package:cli_app/src/data/database.dart';
import 'package:cli_app/src/models/firebase_app_details.dart';
import 'package:cli_app/src/models/flutter_app_details.dart';
import 'package:cli_app/src/modules/flutter_app/flutter_cli.dart';
import 'package:cli_app/src/templates/domain/firebase/firebase_package_manager.dart';
import 'package:cli_app/src/templates/domain/token.dart';
import 'package:uuid/uuid.dart';

class FirebaseAppException implements Exception {
  final String message;
  FirebaseAppException(this.message);
}

class FlutterFireCli {
  FlutterFireCli._();
  static FlutterFireCli get instance => FlutterFireCli._();
  final AdireCliProcess process = AdireCliProcess();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<FirebaseOptions> selectedOptions = [];

  Future<FirebaseAppDetails> getFirebaseAppDetails(String name) async {
    getOptions();
    String firebaseToken = await getFirebaseCliToken();
    final projectId = await getAppId(firebaseToken, name);
    FirebaseAppDetails details = FirebaseAppDetails(
      projectId: projectId.$1,
      projectName: projectId.$2,
      cliToken: firebaseToken,
      selectedOptions: selectedOptions,
    );
    details = await _loadFirebaseOptions(details);
    return details;
  }

  void getOptions() {
    List<FirebaseOptions> options = List.from(FirebaseOptions.values);
    options.remove(FirebaseOptions.core);
    final selectedOptionIndex = process.getMultiSelectInput(
      prompt: 'What firebase options would you like?',
      options: options.names,
    );
    selectedOptions = selectedOptionIndex.map((e) => options[e]).toList();
  }

  Future<String> getFirebaseCliToken() async {
//TODO:  firebase CLI token is deprecated use service accounts
    String firebaseToken;
    final results = await databaseHelper.query(
      where: '',
      whereArgs: [],
      columns: [],
    );
    if (results.isNotEmpty) {
      final token = results.first['value'] as String;
      firebaseToken = token;
    } else {
      firebaseToken = process.getInput(
        prompt: 'Enter your Firebase CLI token',
        initialText: token2,
        validator: (val) => AppValidators.notNullAndNotEmpty(val,
            message: 'Token cannot be empty'),
      );
      await databaseHelper.insertUpdate({
        'id': 'firebase_ci',
        'value': firebaseToken,
      });
    }
    return firebaseToken;
  }

  Future<(String, String)> getAppId(String token, String name) async {
    final appId = await _listProject(token);
    // return (appId['id']! as String, appId['name']! as String);
    //TODO: solve FirebaseProjectNotFoundException error to create a new project

    if (appId == null) {
      return _createAppId(token, name);
    } else {
      return (appId['id']! as String, appId['name']! as String);
    }
  }

  Future<Map<dynamic, dynamic>?> _listProject(String token) async {
    final result = await process.run(
      'firebase',
      streamInput: false,
      arguments: ['projects:list', '--token', '$token'],
      showInlineResult: false,
      showSpinner: true,
      spinnerMessage: (done) =>
          done ? 'Gotten Firebase projects' : 'Gathering Firebase projects',
    );

    final projectDetails = _extractProjectDetails(result!.stdout);

    final projectIndex = process.getSelectInput(
      prompt:
          'Select a Firebase project to configure your Flutter application with',
      options: projectDetails.map((e) => '${e['name']}(${e['id']})').toList()
        ..add('<create a new project>'),
    );

    if (projectIndex == projectDetails.length) {
      return null;
    } else {
      m('Configuring Flutter with ${projectDetails[projectIndex]}');
      return projectDetails[projectIndex];
    }
  }

  Future<(String, String)> _createAppId(
      String token, String projectName) async {
    try {
      final name = process.getInput(
        prompt: 'Enter a project name for your new firebase project',
        defaultValue: projectName,
        validator: AppValidators.isFirebaseProjectIdValid,
      );
      String uniqueID = Uuid().v4();
      uniqueID = uniqueID.substring(0, 8);
      final projectId = '${name}';
      // final projectId = '${name + '-' + uniqueID}';
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
      await process.delayProcess(30, 'Waiting for Firebase Project Sync');

      return (projectId, name);
    } on FirebaseAppException catch (error) {
      e(error.message);
      return _createAppId(token, projectName);
    } on Exception catch (error) {
      e('Something went wrong ${error.toString()}');
      rethrow;
    }
  }

  Future<void> initializeFirebase(FlutterAppDetails flutterAppDetails) async {
    await FlutterCli.instance
        .activate('flutterfire_cli', flutterAppDetails.path);

    await _configure(flutterAppDetails);
    FirebasePackageManager.getPackages(flutterAppDetails);

    m('FlutterFireCli init done');
  }

  Future<void> _configure(FlutterAppDetails flutterAppDetails) async {
    if (flutterAppDetails.firebaseAppDetails != null) {
      final dir = Directory(flutterAppDetails.path);
      m('Configuring FlutterFire $dir');
      final export = [
        'export PATH="\$PATH":"<span class="math-inline">HOME/.pub-cache/bin" '
      ];
      final flutterFire =
          'flutterfire configure --project=${flutterAppDetails.firebaseAppDetails?.projectId} --platforms=${flutterAppDetails.platforms.map((e) => e.name).toList().join(',')} --token ${flutterAppDetails.firebaseAppDetails?.cliToken}';

      await process.run('bash',
          arguments: ['-c', 'dart pub global activate flutterfire_cli'],
          workingDirectory: flutterAppDetails.path);
      await process.run(
        'bash',
        arguments: ['-l', '-c', ...export],
        workingDirectory: flutterAppDetails.path,
      );
      await process.run(
        'bash',
        streamInput: false,
        arguments: ['-l', '-c', flutterFire],
        showSpinner: true,
        spinnerMessage: (done) => done
            ? 'Configured Firebase project'
            : 'Configuring Firebase project',
        workingDirectory: flutterAppDetails.path,
      );
      m('Configuring done');
    } else {
      m('Firebase project not defined, skipping');
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

  Future<FirebaseAppDetails> _loadFirebaseOptions(
      FirebaseAppDetails firebaseAppDetails) async {
    if (selectedOptions.contains(FirebaseOptions.authentication)) {
      final options = await _getAuthenticationOptions();
      firebaseAppDetails = firebaseAppDetails.copyWith(
        authenticationMethods: options,
      );
    }
    return firebaseAppDetails;
  }

  Future<List<AuthenticationMethod>> _getAuthenticationOptions() async {
    const options = AuthenticationMethod.values;
    final answerIndexes = process.getMultiSelectInput(
      prompt: 'Please select authentication options',
      options: options.names,
      defaultValue: [AuthenticationMethod.email.name],
    );
    if (answerIndexes.isEmpty) {
      e('Please select an authentication option');
      _getAuthenticationOptions();
    }
    final answers = options
        .where((element) => answerIndexes.contains(options.indexOf(element)))
        .toList();
    m('You selected: ${answers.names.joined}');
    return answers;
  }

  Future<void> _enableEmailPassWordSignIn() async {
    HttpProcess http = HttpProcess();
    final url =
        "https://identitytoolkit.clients6.google.com/v2/projects/zappy-a16eeb8e/config?updateMask=signIn.email.enabled,signIn.email.passwordRequired&alt=json&key=AIzaSyDovLKo3djdRbs963vqKdbj-geRWyzMTrg";
    http.patchData(url);
  }
}
