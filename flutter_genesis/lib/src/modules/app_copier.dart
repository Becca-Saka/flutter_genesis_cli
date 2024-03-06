import 'dart:io';

import 'package:flutter_genesis/src/models/flutter_app_details.dart';

import 'pattern_replace.dart';

class AppCopier {
  Future<void> copyFiles({
    required String sourcePath,
    required FlutterAppDetails appDetails,
  }) async {
    Directory dir = Directory('launcher/$sourcePath');
    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        String relativePath = entity.path.substring(dir.path.length);
        final pathDart = relativePath.splitMapJoin('.dart');
        final pathDartSplited = pathDart.split('/');

        final pathDartList = List.from(pathDartSplited)..removeLast();
        relativePath = pathDartList.join('/');
        String destinationPath =
            _setUpByManager('${appDetails.path}/$sourcePath', relativePath);
        String newDestinationPath =
            '${destinationPath}/${pathDartSplited.last}';
        var destinationFile = File('$newDestinationPath');

        if (canCopyFile(appDetails, pathDartSplited.last)) {
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

          await destinationFile.writeAsString(modifiedContent);
        }
      }
    }
  }

  bool canCopyFile(FlutterAppDetails appDetails, String path) {
    final authPaths = [
      'firebase_options.dart',
      'sign_in_page.dart',
      'sign_up_page.dart',
      'auth_services.dart',
    ];
    if (appDetails.firebaseAppDetails == null) {
      if (authPaths.contains(path)) {
        return false;
      }
    }

    return true;
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
