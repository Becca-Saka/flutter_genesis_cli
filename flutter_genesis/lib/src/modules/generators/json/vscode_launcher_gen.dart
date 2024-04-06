import 'dart:io';

import 'package:flutter_genesis/src/commands/process/process.dart';
import 'package:flutter_genesis/src/modules/file_modifier.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';

class VsCodeLauncherGenerator {
  late FlutterAppDetails appDetails;
  FlutterGenesisCli _flutterGenesisCli = FlutterGenesisCli();

  Future<void> create(FlutterAppDetails app) async {
    if (app.flavorModel != null) {
      final response = _flutterGenesisCli.getConfirmation(
        prompt: 'Do you want to generate vscode launch.json?',
        defaultValue: true,
      );
      if (response) {
        appDetails = app;

        await _generateBuildScript();
      }
    }
  }

  Future<File> _generateBuildScript() async {
    File file = File("${appDetails.path}/.vscode/launch.json");
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    final flavors = appDetails.flavorModel!.environmentOptions;

    String contents = '''
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
''';
    final fileName = writeInLoop(
      tempEnv: flavors,
      line: (flavor) {
        return ''' {
            "name": "${appDetails.name}($flavor)",
            "request": "launch",
            "type": "dart",
            "program": "lib/app/src/$flavor/main_$flavor.dart",
            
            "args": ["--flavor", "$flavor", "--target", "lib/app/src/$flavor/main_$flavor.dart", "--verbose",]
        },''';
      },
    );
    contents += fileName;

    contents += '''
    ]
}
''';
    return await file.writeAsString(contents);
  }
}
