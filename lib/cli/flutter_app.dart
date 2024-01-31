// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:cli_app/shared/validators.dart';

import '../process/process.dart';
import 'flutter_cli.dart';

class FlutterAppDetails {
  final String name;
  final String path;
  final String packageName;
  FlutterAppDetails({
    required this.name,
    required this.path,
    required this.packageName,
  });
}

class FlutterApp {
  FlutterApp._();
  static FlutterApp get instance => FlutterApp._();
  AdireCliProcess process = AdireCliProcess();
  FlutterAppDetails init() {
    String name = getAppName();
    String path = getPath();
    String package = getPackageName(name);

    return FlutterAppDetails(
      name: name,
      path: path,
      packageName: package,
    );
  }

  String getAppName() {
    String? name = process.getInput(
      prompt: 'What Should We call your project?',
      validator: (val) => AppValidators.notNullAndNotEmpty(val,
          message: 'Name cannot be empty'),
    );
    name = name.toLowerCase();
    //replace space with underscore
    name = name.replaceAll(' ', '_');
    return name;
  }

  String getPath() {
    String path = process.getInput(
      prompt: 'Where is your project located?(press enter to use current path)',
      defaultValue: Directory.current.path,
    );
    if (path.isEmpty) {
      return Directory.current.path;
    } else {
      return path;
    }
  }

  String getPackageName(String name) {
    print('What is the package name?(press enter to use com.example.$name)');
    String? package = process.getInput(
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
      FlutterAppDetails appDetails, String workingDirectory) async {
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
        '${appDetails.name}'
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
        '${appDetails.packageName}'
      ],
      workingDirectory,
    );

    //flutter pub run change_app_package_name:main com.new.package.name
    // await FlutterCli.instance.pubRun(
    //   ['change_app_package_name:main', '${appDetails.packageName}'],
    //   workingDirectory,
    // );
  }
  // Future<void> updateAppDetails(
  //     FlutterAppDetails appDetails, String workingDirectory) async {
  //   await FlutterCli.instance.pubAdd(
  //     ['change_app_package_name', 'rename_app'],
  //     workingDirectory,
  //   );
  //   // flutter pub run rename_app:main all="My App Name"
  //   await FlutterCli.instance.pubRun(
  //     ['rename_app:main', 'all=${appDetails.name}'],
  //     workingDirectory,
  //   );
  //   //flutter pub run change_app_package_name:main com.new.package.name
  //   await FlutterCli.instance.pubRun(
  //     ['change_app_package_name:main', '${appDetails.packageName}'],
  //     workingDirectory,
  //   );
  // }
}
