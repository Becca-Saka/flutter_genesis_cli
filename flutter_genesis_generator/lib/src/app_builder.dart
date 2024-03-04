import 'dart:async';
import 'dart:io';

import 'package:build/build.dart' hide log;

String replaceByPattern(
  String inputContent, {
  required String oldPattern,
  required String newPattern,
}) {
  return inputContent.replaceAllMapped(
    RegExp(r'' + oldPattern),
    (match) => newPattern,
  );
}

class AppCopierBuilder implements Builder {
  final BuilderOptions options;

  AppCopierBuilder(this.options);

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.gen.dart']
      };
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    AssetId inputId = buildStep.inputId;
    String inputContent = await buildStep.readAsString(inputId);

    final sourceDirectory = 'launcher/lib';

    final destinationDirectory = options.config['destinationDirectory'];
    if (inputId.path.startsWith(sourceDirectory)) {
      String relativePath = inputId.path.substring(sourceDirectory.length);
      if (relativePath.endsWith('.dart')) {
        final pathDart = relativePath.splitMapJoin('.dart');
        final pathDartList = pathDart.split('/')..removeLast();
        relativePath = pathDartList.join('/');
      }

      String destinationPath =
          _setUpByManager(destinationDirectory, relativePath);

      await Directory(destinationPath).create(recursive: true);

      // Copy the file content to the destination
      final destinationFile =
          File('$destinationPath/${inputId.pathSegments.last}');
      inputContent = replaceByPattern(
        inputContent,
        oldPattern: "import 'package:launcher/",
        newPattern: "import 'package:${options.config['appName']}/",
      );
      await destinationFile.writeAsString(inputContent);
    }
  }

  String _setUpByManager(
    String destinationDirectory,
    String relativePath,
  ) {
    String destinationPath = '';
    if (relativePath.endsWith('services')) {
      destinationPath = '$destinationDirectory/data/$relativePath';
    } else {
      destinationPath = '$destinationDirectory$relativePath';
    }
    return destinationPath;
  }
}
