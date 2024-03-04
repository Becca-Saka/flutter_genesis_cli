import 'dart:io';

import 'package:flutter_genesis/src/common/extensions/lists.dart';
import 'package:flutter_genesis/src/common/logger.dart';
import 'package:flutter_genesis/src/common/process/process.dart';
import 'package:flutter_genesis/src/common/validators.dart';
import 'package:flutter_genesis/src/models/firebase_app_details.dart';
import 'package:flutter_genesis/src/models/flutter_app_details.dart';
import 'package:flutter_genesis/src/templates/domain/firebase/flutter_fire_cli.dart';
import 'package:flutter_genesis/src/templates/template_options.dart';

///Handles the flutter app creation process.
///
///
class FlutterApp {
  FlutterApp._();
  static FlutterApp get instance => FlutterApp._();
  AdireCliProcess process = AdireCliProcess();

  Future<FlutterAppDetails> init() async {
    final name = getAppName();
    final path = getPath();
    final package = getPackageName(name);
    final stateManager = getStateManagerOptions();
    final templates = getTemplateOptions();
    final platforms = getPlatformOptions();
    final firebaseAppDetails = await loadTemplateOptions(templates, name);
    final flutterAppDetails = FlutterAppDetails(
      name: name,
      path: path,
      packageName: package,
      templates: templates,
      platforms: platforms,
      firebaseAppDetails: firebaseAppDetails,
      stateManager: stateManager,
    );
    return await _createApp(flutterAppDetails);
  }

  Future<FlutterAppDetails> _createApp(
      FlutterAppDetails flutterAppDetails) async {
    await process.run(
      'flutter',
      arguments: [
        'create',
        '--org',
        '${flutterAppDetails.packageName}',
        '--platforms=${flutterAppDetails.platforms.map((e) => e.name).toList().join(',')}',
        flutterAppDetails.name
      ],
      workingDirectory: flutterAppDetails.path,
      runInShell: true,
    );
    return flutterAppDetails.copyWith(
      path: flutterAppDetails.path + '/' + flutterAppDetails.name,
    );
  }

  String getAppName() {
    String? name = process.getInput(
      prompt: 'What should we call your project?',
      validator: (val) => AppValidators.notNullAndNotEmpty(
        val,
        message: 'Name cannot be empty',
      ),
    );
    name = name.toLowerCase();
    //replace space with underscore
    name = name.replaceAll(' ', '_');
    return name;
  }

  String getPath() {
    // String appPath = Directory.current.path;
    String appPath = Directory.current.parent.path + '/examples';
    final path = process.getInput(
      prompt: 'Where is your project located?',
      defaultValue: appPath,
    );
    if (path.isNotEmpty) {
      appPath = path;
    }

    if (!Directory(appPath).existsSync()) {
      Directory(appPath).createSync(recursive: true);
    }
    return appPath;
  }

  String getPackageName(String name) {
    final package = process.getInput(
      prompt: 'What is the package name?',
      defaultValue: 'com.example.$name',
      validator: AppValidators.isValidFlutterPackageName,
    );

    return package;
  }

  List<FlutterAppPlatform> getPlatformOptions() {
    const options = FlutterAppPlatform.values;
    final answerIndexes = process.getMultiSelectInput(
      prompt: 'What platform should your project be initialized for?',
      options: options.names,
      defaultValue: [
        FlutterAppPlatform.android.name,
        FlutterAppPlatform.ios.name,
      ],
    );
    if (answerIndexes.isEmpty) {
      e('Please select a platform');
      getPlatformOptions();
    }
    final answers = options
        .where((element) => answerIndexes.contains(options.indexOf(element)))
        .toList();
    m('You selected: ${answers.names.joined}');

    return answers;
  }

  StateManager getStateManagerOptions() {
    const options = StateManager.values;
    final answerIndex = process.getSelectInput(
      prompt: 'What state manager should your project be initialized with?',
      options: options.names,
      defaultValue: StateManager.bloc.name,
    );
    final answer = options[answerIndex];
    m('You selected: ${answer}');

    return answer;
  }

  List<TemplateOptions> getTemplateOptions() {
    const options = TemplateOptions.values;
    final answerIndexes = process.getMultiSelectInput(
      prompt: 'What would you like to initialize?',
      options: options.names,
    );
    final answers = options
        .where((element) => answerIndexes.contains(options.indexOf(element)))
        .toList();
    m('You selected: ${answers.names.joined}');
    return answers;
  }

  Future<FirebaseAppDetails?> loadTemplateOptions(
    List<TemplateOptions> options,
    String name,
  ) async {
    if (options.contains(TemplateOptions.firebase)) {
      final firebaseAppDetails =
          await FlutterFireCli.instance.getFirebaseAppDetails(name);
      return firebaseAppDetails;
    }
    return null;
  }

  String getFirebaseProjectId() {
    return process.getInput(
      prompt: 'Enter your Firebase project ID/Name',
      validator: (val) => AppValidators.notNullAndNotEmpty(
        val,
        message: 'Project ID cannot be empty',
      ),
    );
  }

  String getFirebaseCliToken() {
    return process.getInput(
      prompt: 'Enter your Firebase CLI token',
      validator: (val) => AppValidators.notNullAndNotEmpty(
        val,
        message: 'Token cannot be empty',
      ),
    );
  }
}
