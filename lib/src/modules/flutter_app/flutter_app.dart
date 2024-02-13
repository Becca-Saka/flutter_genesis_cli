import 'dart:io';

import 'package:cli_app/src/common/extensions/lists.dart';
import 'package:cli_app/src/common/logger.dart';
import 'package:cli_app/src/common/process/process.dart';
import 'package:cli_app/src/common/validators.dart';
import 'package:cli_app/src/models/firebase_app_details.dart';
import 'package:cli_app/src/models/flutter_app_details.dart';
import 'package:cli_app/src/modules/flutter_app/flutter_cli.dart';
import 'package:cli_app/src/templates/domain/firebase/flutter_fire_cli.dart';
import 'package:cli_app/src/templates/template_options.dart';

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
    final templates = getTemplateOptions();
    final platforms = getPlatformOptions();
    final firebaseAppDetails = await loadTemplateOptions(templates, name);

    return FlutterAppDetails(
      name: name,
      path: path,
      packageName: package,
      templates: templates,
      platforms: platforms,
      firebaseAppDetails: firebaseAppDetails,
    );
  }

  String getAppName() {
    String? name = process.getInput(
      prompt: 'What Should We call your project?',
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
    final path = process.getInput(
      prompt: 'Where is your project located?',
      defaultValue: Directory.current.path,
    );
    if (path.isEmpty) {
      return Directory.current.path;
    } else {
      return path;
    }
  }

  String getPackageName(String name) {
    final package = process.getInput(
      prompt: 'What is the package name?',
      defaultValue: 'com.example.$name',
      validator: AppValidators.isValidFlutterPackageName,
    );

    return package;
  }

//TODO: not app value renames, find a way to remove all traces of 'adire_init_app"
/*
 affected files
1. Runner.xcscheme - Macos
2. Pubspec.yaml
3. Readme.md
4. CMakeLists.txt - Linux
5. my_application.cc - Linux
6. project.pbxproj - Macos
7. widget_test.dart 
8. index.html - Web
9. Runner.rc - Windows
 -- found a way, painstankinly remove all traces of 'adire_init_app" manually by using {{name}} 
*/

  Future<void> updateAppDetails(
    FlutterAppDetails appDetails,
    String workingDirectory,
  ) async {
    await FlutterCli.instance.pubAdd(
      ['rename'],
      workingDirectory,
    );
    await FlutterCli.instance.activate(
      'rename',
      workingDirectory,
    );
    // flutter pub global activate rename
    // flutter pub run rename_app:main all="My App Name"
    //rename setAppName --targets ios,android --value "YourAppName"
    //
    await FlutterCli.instance.pubRun(
      [
        'rename',
        'setAppName',
        '--targets',
        'ios,android,web,windows,macos,linux',
        '--value',
        appDetails.name,
      ],
      workingDirectory,
    );
    //rename setBundleId --targets android --value "com.example.bundleId"
    // await FlutterCli.instance.pubRun(
    //   ['rename_app:main', 'all=${appDetails.name}'],
    //   workingDirectory,
    // );
    await FlutterCli.instance.pubRun(
      [
        'rename',
        'setBundleId',
        '--targets',
        'ios,android,web,windows,macos,linux',
        '--value',
        appDetails.packageName,
      ],
      workingDirectory,
    );

    //flutter pub run change_app_package_name:main com.new.package.name
    // await FlutterCli.instance.pubRun(
    //   ['change_app_package_name:main', '${appDetails.packageName}'],
    //   workingDirectory,
    // );
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
