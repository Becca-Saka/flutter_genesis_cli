import 'dart:io';

import 'package:flutter_genesis/src/shared/extensions/lists.dart';
import 'package:flutter_genesis/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';
import 'package:path/path.dart';

import 'pattern_replace.dart';

Future<void> copyFiles({
  required String sourcePath,
  required FlutterAppDetails appDetails,
}) async {
  Directory dir = Directory('launcher/$sourcePath');
  await for (var entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      final destinationFile = _getNewPath(
        appDetails: appDetails,
        dirPath: dir.path,
        entityPath: entity.path,
        sourcePath: sourcePath,
      );
      final baseName = basename(entity.path);
      if (canCopyFile(appDetails, baseName)) {
        await destinationFile.create(recursive: true);
        var content = await entity.readAsString();
        String modifiedContent = _changeAppImportName(content, appDetails);

        modifiedContent = replaceByPattern(
          modifiedContent,
          oldPattern: "/services/",
          newPattern: "/data/services/",
        );

        modifiedContent =
            _modifyAuthFiles(appDetails, modifiedContent, baseName);

        await destinationFile.writeAsString(modifiedContent);
      }
    }
  }
}

File _getNewPath({
  required String dirPath,
  required String entityPath,
  required String sourcePath,
  required FlutterAppDetails appDetails,
}) {
  String relativePath = entityPath.substring(dirPath.length);
  final joinPart = split(relativePath);
  final joinPartSplited = List<String>.from(joinPart)..removeLast();
  relativePath = joinAll(joinPartSplited);

  String destinationPath =
      _setUpByManager('${appDetails.path}/$sourcePath', relativePath);
  final baseName = basename(entityPath);
  String newDestinationPath = '${destinationPath}/${baseName}';
  newDestinationPath = normalize(newDestinationPath);

  var destinationFile = File('$newDestinationPath');

  return destinationFile;
}

String _changeAppImportName(String content, FlutterAppDetails appDetails) {
  var modifiedContent = replaceByPattern(
    content,
    oldPattern: "import 'package:launcher/",
    newPattern: "import 'package:${appDetails.name}/",
  );
  return modifiedContent;
}

String _modifyAuthFiles(
  FlutterAppDetails appDetails,
  String content,
  String baseName,
) {
  if (baseName.endsWith('auth_services.dart') ||
      baseName.endsWith('sign_in_page.dart')) {
    if (appDetails.firebaseAppDetails != null) {
      final hasAuth = appDetails.firebaseAppDetails!.selectedOptions
          .hasValue(FirebaseOptions.authentication);

      if (hasAuth) {
        final hasFirestore = appDetails.firebaseAppDetails!.selectedOptions
            .hasValue(FirebaseOptions.firestore);
        final hasGoogleSignIn = appDetails
                .firebaseAppDetails!.authenticationMethods
                ?.hasValue(AuthenticationMethod.google) ??
            false;

        if (!hasFirestore) {
          content = removeLinesBetweenMarkers(content.split('\n'), 'firestore');
        }
        if (!hasGoogleSignIn) {
          content =
              removeLinesBetweenMarkers(content.split('\n'), 'googleAuth');
        }
      }
    }
  }
  return content;
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
  if (path.endsWith('firebase_options.dart')) {
    return false;
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
