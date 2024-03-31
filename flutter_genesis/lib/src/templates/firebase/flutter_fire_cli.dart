import 'dart:io';

import 'package:flutter_genesis/src/commands/process/http_procress.dart';
import 'package:flutter_genesis/src/commands/process/process.dart';
import 'package:flutter_genesis/src/modules/flutter_app/flutter_cli.dart';
import 'package:flutter_genesis/src/shared/database.dart';
import 'package:flutter_genesis/src/shared/extensions/lists.dart';
import 'package:flutter_genesis/src/shared/logger.dart';
import 'package:flutter_genesis/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';
import 'package:flutter_genesis/src/shared/validators.dart';
import 'package:flutter_genesis/src/templates/firebase/firebase_package_manager.dart';
import 'package:flutter_genesis/src/templates/flavors/flavors_manager.dart';
import 'package:flutter_genesis/src/templates/token.dart';
import 'package:tint/tint.dart';
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

  Future<FirebaseAppDetails> getFirebaseAppDetails(
    String appName,
    FlavorModel? flavors,
  ) async {
    String firebaseToken = await getFirebaseCliToken();
    getOptions();
    FirebaseAppDetails details = FirebaseAppDetails(
      // projectId: projectId.$1,
      // projectName: projectId.$2,
      cliToken: firebaseToken,
      selectedOptions: selectedOptions,
    );
    if (useFlavors(flavors)) {
      assert(flavors != null);
      final namesByFlavor = flavors!.name;
      final flavorsEnvironment = flavors.environmentOptions;
      details.flavorConfigs ??= [];
      for (var i = 0; i < flavorsEnvironment.length; i++) {
        final name = namesByFlavor?.entries.elementAt(i).value ?? appName;
        final flavor = flavorsEnvironment[i];
        final packageName = flavors.packageId![flavor]!;
        m('Configuring Firebase project for' + ' $name'.bold() + '-${flavor}');
        final projectId = await getAppId(
          token: firebaseToken,
          name: '${name}-${flavor}',
          validator: (p0) {
            final valid = details.flavorConfigs!.where((element) =>
                element.projectId == p0 && element.packageName == packageName);

            return valid.isEmpty;
          },
        );

        details.flavorConfigs!.add(FirebaseFlavorConfig(
          flavor: flavor,
          projectId: projectId.$1,
          projectName: projectId.$2,
          packageName: packageName,
        ));
      }

      // await process.delayProcess(30, 'Waiting for Firebase Project Sync');
    } else {
      final projectId = await getAppId(
        token: firebaseToken,
        name: appName,
        validator: (_) => true,
      );
      // final projectId = await getAppId(firebaseToken, appName);
      details = details.copyWith(
        projectId: projectId.$1,
        projectName: projectId.$2,
      );
    }

    // FirebaseAppDetails details = FirebaseAppDetails(
    //   projectId: projectId.$1,
    //   projectName: projectId.$2,
    //   cliToken: firebaseToken,
    //   selectedOptions: selectedOptions,
    // );
    details = await _loadFirebaseOptions(details);
    return details;
  }

  bool useFlavors(FlavorModel? flavors) {
    if (flavors != null) {
      return process.getConfirmation(
        prompt:
            'Would you like to generate different firebase project for your flavors?',
        defaultValue: false,
      );
    }
    return false;
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
        initialText: tokenAdire,
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
      // if (!isFlavor) {
      await process.delayProcess(25, 'Waiting for Firebase Project Sync');
      // }

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
    await FlutterCli.activate('flutterfire_cli', flutterAppDetails.path);

    await _configure(flutterAppDetails);
    FirebasePackageManager.getPackages(flutterAppDetails);

    m('FlutterFireCli init done');
  }

  Future<void> _configure(FlutterAppDetails flutterAppDetails) async {
    final firebaseAppDetails = flutterAppDetails.firebaseAppDetails;
    if (firebaseAppDetails != null) {
      final dir = Directory(flutterAppDetails.path);
      m('Configuring FlutterFire $dir');
      final export = [
        'export PATH="\$PATH":"<span class="math-inline">HOME/.pub-cache/bin" '
      ];
      await process.run('bash',
          arguments: ['-c', 'dart pub global activate flutterfire_cli'],
          workingDirectory: flutterAppDetails.path);
      await process.run(
        'bash',
        arguments: ['-l', '-c', ...export],
        workingDirectory: flutterAppDetails.path,
      );

      final token = firebaseAppDetails.cliToken;
      final platforms =
          flutterAppDetails.platforms.map((e) => e.name).toList().join(',');
      final flavorModel = flutterAppDetails.flavorModel;
      final flavorConfigs = firebaseAppDetails.flavorConfigs;
      final appPath = flutterAppDetails.path;
      if (flavorModel != null && flavorConfigs != null) {
        for (int i = 0; i < flavorModel.environmentOptions.length; i++) {
          final flavor = flavorModel.environmentOptions[i];
          String args = ' --out=lib/app/src/$flavor/firebase_options.dart';
          args += ' --android-package-name=${flavorModel.packageId![flavor]}';
          args += ' --ios-bundle-id=${flavorModel.packageId![flavor]}';
          final firebaseFlavorConfig =
              flavorConfigs.firstWhere((element) => element.flavor == flavor);

          await _configureFirebase(
            projectId: firebaseFlavorConfig.projectId,
            token: token,
            args: args,
            platforms: platforms,
            path: appPath,
          );

          if (flutterAppDetails.platforms.contains(FlutterAppPlatform.ios)) {
            await _moveFiles(
              appPath: appPath,
              newPath: '${appPath}/ios/Runner/config/${flavor}',
              oldPath: '${appPath}/ios/Runner/GoogleService-Info.plist',
            );

            await _moveFiles(
              appPath: appPath,
              newPath: '${appPath}/ios/Runner/config/${flavor}',
              oldPath: '${appPath}/ios/firebase_app_id_file.json',
            );
          }
          if (flutterAppDetails.platforms
              .contains(FlutterAppPlatform.android)) {
            await _moveFiles(
              appPath: appPath,
              newPath: '${appPath}/android/app/src/${flavor}',
              oldPath: '${appPath}/android/app/google-services.json',
            );
          }
        }
      } else {
        await _configureFirebase(
          projectId: firebaseAppDetails.projectId!,
          token: token,
          args: '',
          platforms: platforms,
          path: appPath,
        );
      }
      m('Configuring done');
    } else {
      m('Firebase project not defined, skipping');
    }
  }

  Future<void> _moveFiles({
    required String newPath,
    required String oldPath,
    required String appPath,
  }) async {
    if (!Directory(newPath).existsSync()) {
      Directory(newPath).createSync(recursive: true);
    }
    await process.run(
      'mv',
      arguments: [
        oldPath,
        newPath,
      ],
      workingDirectory: appPath,
      streamOutput: false,
    );
  }

  Future<void> _configureFirebase({
    required String projectId,
    required String token,
    required String args,
    required String platforms,
    required String path,
  }) async {
    String flutterFire = 'flutterfire configure --project=${projectId}';
    flutterFire += args;
    flutterFire += ' --platforms=${platforms} --token ${token}';
    // final flutterFire =
    //     'flutterfire configure --project=${flutterAppDetails.firebaseAppDetails?.projectId} --platforms=${flutterAppDetails.platforms.map((e) => e.name).toList().join(',')} --token ${flutterAppDetails.firebaseAppDetails?.cliToken}';

    await process.run(
      'bash',
      streamOutput: false,
      arguments: ['-l', '-c', flutterFire],
      showSpinner: true,
      spinnerMessage: (done) =>
          done ? 'Configured Firebase project' : 'Configuring Firebase project',
      workingDirectory: path,
    );
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
