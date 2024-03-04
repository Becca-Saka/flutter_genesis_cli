import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';

import 'app_builder.dart';

class AppTestCopierBuilder implements Builder {
  final BuilderOptions options;

  AppTestCopierBuilder(this.options);
  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.gen.dart']
      };
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    AssetId inputId = buildStep.inputId;
    String inputContent = await buildStep.readAsString(inputId);
    if (inputId.path.endsWith('_test.dart')) {
      final appName = options.config['appName'];
      inputContent = replaceByPattern(
        inputContent,
        oldPattern: "import 'package:launcher/",
        newPattern: "import 'package:$appName/",
      );
      final destinationPath = "${options.config['destinationDirectory']}";
      final destinationFile =
          File('$destinationPath/${inputId.pathSegments.last}');
      await destinationFile.writeAsString(inputContent);
    }
  }
}
