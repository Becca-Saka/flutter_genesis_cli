import 'dart:async';
import 'dart:io';

import 'package:build/build.dart' hide log;

class AppCopierBuilder implements Builder {
  final BuilderOptions options;

  AppCopierBuilder(this.options);
  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    AssetId inputId = buildStep.inputId;
    String inputContent = await buildStep.readAsString(inputId);

    final sourceDirectory = 'launcher/lib';

    final destinationDirectory = options.config['destinationDirectory'];

    if (inputId.path.startsWith(sourceDirectory)) {
      // print('  ${inputId.path} $sourceDirectory $destinationDirectory');
      String relativePath = inputId.path.substring(sourceDirectory.length);
      if (relativePath.endsWith('.dart')) {
        final pathDart = relativePath.splitMapJoin('.dart');
        final pathDartList = pathDart.split('/')..removeLast();
        relativePath = pathDartList.join('/');
      }

      String destinationPath = '$destinationDirectory$relativePath';
      print(
          "destinationDirectory: $destinationDirectory relativePath: $relativePath");
      // if (destinationPath.endsWith('services')) {
      //   destinationPath = '$destinationDirectory/data/$relativePath';
      // }
      await Directory(destinationPath).create(recursive: true);

      // Copy the file content to the destination
      final destinationFile =
          File('$destinationPath/${inputId.pathSegments.last}');
      inputContent = inputContent.replaceAllMapped(
        RegExp(r"import 'package:launcher/"),
        (match) => "import 'package:${options.config['appName']}/",
      );
      // final stateManager = options.config['stateManager'];
      await destinationFile.writeAsString(inputContent);
    }
  }

  void _copyByPattern(
    String sourceDirectory,
    String destinationDirectory,
    String pattern,
  ) {}

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart']
      };
}
