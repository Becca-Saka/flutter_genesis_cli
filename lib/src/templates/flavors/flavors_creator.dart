import 'dart:io';

import 'package:flutter_genesis_cli/src/commands/process/process.dart';
import 'package:flutter_genesis_cli/src/modules/file_modifier.dart';
import 'package:flutter_genesis_cli/src/modules/flutter_app/flutter_cli.dart';
import 'package:flutter_genesis_cli/src/modules/generators/script/firebase_json_script_generator.dart';
import 'package:flutter_genesis_cli/src/modules/generators/yaml/yaml_generator.dart';
import 'package:flutter_genesis_cli/src/modules/pattern_replace.dart';
import 'package:flutter_genesis_cli/src/shared/logger.dart';
import 'package:flutter_genesis_cli/src/shared/models/flutter_app_details.dart';
import 'package:path/path.dart';

class FlavorCreator {
  FlutterGenesisCli process = FlutterGenesisCli();
  YamlGenerator yamlGenerator = YamlGenerator();

  Future<void> createFlavor(FlutterAppDetails appDetails) async {
    m('Creating flavors');
    await _installDependencies();
    _createYamlFile(appDetails);
    await _installFlavorizr(appDetails);

    if (appDetails.firebaseAppDetails?.flavorConfigs != null) {
      await FirebaseJsonScriptGenerator().create(appDetails);
    }
  }

  Future<void> _installDependencies() async {
    await _installRuby();
    await _installXcodeproj();
  }

  Future<void> _installRuby() async {
    final result = await process.run(
      'ruby',
      arguments: ['-v'],
      showInlineResult: false,
      streamOutput: false,
      catchErrorInline: false,
    );
    if (result!.exitCode != 0) {
      m('Ruby not installed, installing');
      process.run('brew', arguments: ['install', 'ruby']);
    } else {
      m('Ruby installed, skipping');
    }
  }

  Future<void> _installXcodeproj() async {
    final result = await process.run(
      'xcodeproj',
      arguments: ['--version'],
      showInlineResult: false,
      streamOutput: false,
      catchErrorInline: false,
    );
    if (result!.exitCode != 0) {
      m('xcodeproj not installed, installing');
      process.run('gem', arguments: ['install', 'xcodeproj']);
    } else {
      m('xcodeproj installed, skipping');
    }
  }

  void _createYamlFile(FlutterAppDetails appDetails) {
    appDetails = _addFirebaseFlavors(appDetails);
    yamlGenerator.generateFlavorizrConfig(appDetails);
  }

  FlutterAppDetails _addFirebaseFlavors(FlutterAppDetails flutterAppDetails) {
    final appPath = flutterAppDetails.path;
    flutterAppDetails.flavorModel!.firebaseConfig = {};
    if (flutterAppDetails.firebaseAppDetails?.flavorConfigs != null) {
      for (var flavor in flutterAppDetails.flavorModel!.environmentOptions) {
        final googleJsonPath =
            '${appPath}/android/app/src/${flavor}/google-services.json';
        final infoPlistPath =
            '${appPath}/ios/Runner/config/${flavor}/GoogleService-Info.plist';
        flutterAppDetails.flavorModel!.firebaseConfig![flavor] = {
          'iosPath': infoPlistPath,
          'androidPath': googleJsonPath,
        };
      }
    }
    return flutterAppDetails;
  }

  Future<void> _installFlavorizr(FlutterAppDetails appDetails) async {
    await process.run(
      'dart',
      streamOutput: false,
      arguments: ['pub', 'add', '-d', 'flutter_flavorizr'],
      workingDirectory: appDetails.path,
      runInShell: true,
    );

    await FlutterGenesisCli().delayProcess(5, 'Starting flavorizr');
    await FlutterCli.pubRun(['flutter_flavorizr'], appDetails.path);
  }

  Future<void> modifyNewDestinationFiles(
      {required FlutterAppDetails appDetails}) async {
    readFiles(
      dirPath: '${appDetails.path}/lib',
      onFile: (entity, dir) async {
        if (entity.existsSync()) {
          final baseName = basename(entity.path);
          String content = await entity.readAsString();
          final destinationPath = await _changeFlavorPath(
            dir.path,
            entity.path.substring(dir.path.length),
            baseName,
            content,
            appDetails,
          );

          File destinationFile = new File(destinationPath.$1);

          destinationFile.createSync(recursive: true);

          await destinationFile.writeAsString(destinationPath.$2);
        }
      },
    );
  }

  Future<(String, String)> _changeFlavorPath(
    String destinationDirectory,
    String relativePath,
    String baseName,
    String content,
    FlutterAppDetails flutterAppDetails,
  ) async {
    String destinationPath = '';

    if (flutterAppDetails.flavorModel?.environmentOptions != null) {
      List<String> newLines = [];
      for (var flavor in flutterAppDetails.flavorModel!.environmentOptions) {
        final flavorPath = 'main_${flavor.toLowerCase()}.dart';

        if (baseName.endsWith(flavorPath)) {
          print('-------found: $flavorPath-----');
          final firebaseDetails = flutterAppDetails.firebaseAppDetails;
          if (flutterAppDetails.flavorModel != null) {
            content = replaceByPattern(
              content,
              oldPattern: "import '",
              newPattern: "import 'package:${flutterAppDetails.name}/",
            );
          }
          if (firebaseDetails != null &&
              firebaseDetails.flavorConfigs != null) {
            content = addCodeNearLineInContent(
              content: content,
              condition: 'await runner.main();',
              codeToAddAbove: 'await F.initializeFirebaseApp();',
            );
          }

          destinationPath = '$destinationDirectory/app/src/$flavor/$baseName';
        }
      }
      if (newLines.isNotEmpty) {
        content = newLines.join('\n');
      }

      if (flutterAppDetails.firebaseAppDetails?.flavorConfigs != null) {
        content =
            _addFirebaseFlavorConfig(baseName, content, flutterAppDetails);
      }
    }
    if (destinationPath.isEmpty) {
      destinationPath = '$destinationDirectory$relativePath';
    }

    return (destinationPath, content);
  }

  String _addFirebaseFlavorConfig(
    String baseName,
    String content,
    FlutterAppDetails flutterAppDetails,
  ) {
    if (baseName.endsWith('flavors.dart')) {
      final coreImport = "import 'package:firebase_core/firebase_core.dart';\n";
      final optionsImports = flutterAppDetails.flavorModel!.environmentOptions
          .map((flavor) =>
              "import 'package:${flutterAppDetails.name}/app/src/$flavor/firebase_options.dart' as $flavor;");
      content = addCodeToStartOfFileContent(
          coreImport + optionsImports.join('\n'), content);

      final lines = content.split('\n');

      String addedContent = '''
          static   Future<void> initializeFirebaseApp() async {
        final firebaseOptions = switch (appFlavor) {
        ${flutterAppDetails.flavorModel!.environmentOptions.map((flavor) => ' Flavor.$flavor => $flavor.DefaultFirebaseOptions.currentPlatform,').join('\n')}
        null => ${flutterAppDetails.flavorModel!.environmentOptions.first}.DefaultFirebaseOptions.currentPlatform,
      };
      await Firebase.initializeApp(options: firebaseOptions);
            }
            ''';
      final index = lines.lastIndexOf('}');
      lines[index - 1] += '\n' + addedContent;

      content = lines.join('\n');
    }
    return content;
  }
}
