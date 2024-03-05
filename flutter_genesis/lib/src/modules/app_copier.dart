import 'dart:io';

import 'package:flutter_genesis/src/models/flutter_app_details.dart';

class AppCopier {
  Future<void> copyFiles({
    required String sourcePath,
    required FlutterAppDetails appDetails,
  }) async {
    Directory dir = Directory('launcher/$sourcePath');
    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        print('file at entity.path ${entity.path} ');
        String relativePath = entity.path.substring(dir.path.length);
        final pathDart = relativePath.splitMapJoin('.dart');
        // print('file at pathDart $pathDart ');
        final pathDartSplited = pathDart.split('/');
        final pathDartList = List.from(pathDartSplited)..removeLast();
        // print('file at pathDartList $pathDartList ');
        relativePath = pathDartList.join('/');
        print('file at relativePath $relativePath ');
        String destinationPath =
            _setUpByManager('${appDetails.path}/$sourcePath', relativePath);
        String newDestinationPath =
            '${destinationPath}/${pathDartSplited.last}';
        var destinationFile = File('$newDestinationPath');
        if (!destinationFile.existsSync()) {
          await destinationFile.create(recursive: true);
          var content = await entity.readAsString();
          var modifiedContent = replaceByPattern(
            content,
            oldPattern: "import 'package:launcher/",
            newPattern: "import 'package:${appDetails.name}/",
          );

          modifiedContent = replaceByPattern(
            modifiedContent,
            oldPattern: "/services/",
            newPattern: "/data/services/",
          );

          // content.replaceAll(
          //   "import 'package:launcher/",
          //   "import 'package:${appDetails.name}/",
          // );
          // var modifiedContent = content.replaceAll(
          //   "import 'package:launcher/",
          //   "import 'package:${appDetails.name}/",
          // );
          await destinationFile.writeAsString(modifiedContent);
        }
        print('new file at $newDestinationPath ');
      }
    }
  }

  String replaceByPattern(
    String inputContent, {
    required String oldPattern,
    required String newPattern,
  }) {
    return inputContent.replaceAll(
      oldPattern,
      newPattern,
    );
  }

  String _setUpByManager(
    String destinationDirectory,
    String relativePath,
  ) {
    String destinationPath = '';
    if (relativePath.endsWith('services')) {
      destinationPath = '$destinationDirectory/data$relativePath';
    } else {
      destinationPath = '$destinationDirectory$relativePath';
    }
    return destinationPath;
  }
}
