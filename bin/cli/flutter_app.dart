// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

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
    print('What Should We call your project?');
    String? name = stdin.readLineSync();
    if (name == null || name.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    //to lower case

    name = name.toLowerCase();
    //replace space with underscore
    name = name.replaceAll(' ', '_');
    return name;
  }

  String getPath() {
    print('Where is your project located?(press enter to use current path)');
    String? path = stdin.readLineSync();
    if (path == null || path.isEmpty) {
      return Directory.current.path;
    } else {
      return path;
    }
  }

  String getPackageName(String name) {
    print('What is the package name?(press enter to use com.example.$name)');
    String? package = stdin.readLineSync();
    if (package == null || package.isEmpty) {
      return 'com.example.$name';
    } else {
      //TODO: check if it is a valid package name

      // if (!_isValidFlutterPackageName(name)) {
      //   _clearProcess();
      //   package = null;
      //   print(
      //       '$name is not a valid package name. Please enter a valid package name.');
      //   return getPackageName(name);
      // }
      return package;
    }
  }

  void _clearProcess() {
    if (Platform.isWindows) {
      // not tested, I don't have Windows
      // may not to work because 'cls' is an internal command of the Windows shell
      // not an executeable
      print(Process.runSync("cls", [], runInShell: true).stdout);
    } else {
      print(Process.runSync("clear", [], runInShell: true).stdout);
    }
  }

  bool _isValidFlutterPackageName(String packageName) {
    // Check if the package name follows the specified format
    RegExp validPackagePattern =
        RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$');
    return validPackagePattern.hasMatch(packageName);
  }

/*TODO: not app value renames, find a way to remove all traces of 'adire_init_app"

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
