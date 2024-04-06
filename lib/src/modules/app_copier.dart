import 'dart:io';

import 'package:flutter_genesis_cli/src/shared/extensions/lists.dart';
import 'package:flutter_genesis_cli/src/shared/extensions/string.dart';
import 'package:flutter_genesis_cli/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis_cli/src/shared/models/flutter_app_details.dart';
import 'package:path/path.dart';

import 'file_modifier.dart';
import 'pattern_replace.dart';

class AppCopier {
  Future<void> copyFiles(FlutterAppDetails appDetails) async {
    await readFiles(
      dirPath: 'launcher/lib',
      onFile: (entity, dir) async {
        final destinationFile = _getNewPath(
          dirPath: dir.path,
          entityPath: entity.path,
          flutterAppDetails: appDetails,
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
      },
    );
  }

  File _getNewPath({
    required String dirPath,
    required String entityPath,
    required FlutterAppDetails flutterAppDetails,
  }) {
    String relativePath = entityPath.baseFolder(dirPath.length);
    final destinationDirectory = '${flutterAppDetails.path}/lib';

    String destinationPath =
        _setUpByManager(destinationDirectory, relativePath);

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
            content =
                removeLinesBetweenMarkers(content.split('\n'), 'firestore');
          }
          if (!hasGoogleSignIn) {
            content = removeLinesBetweenMarkers(
              content.split('\n'),
              'googleAuth',
            );
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

  Future<void> cleanUpComments({
    required FlutterAppDetails appDetails,
  }) async {
    final filesToDelete = [
      'lib/app.dart',
      ...appDetails.flavorModel?.environmentOptions
              .map((e) => 'lib/main_$e.dart')
              .toList() ??
          []
    ];
    readFiles(
      dirPath: '${appDetails.path}/lib',
      onFile: (entity, _) async {
        if (entity.existsSync()) {
          if (filesToDelete
              .where((element) => entity.path.endsWith(element))
              .isNotEmpty) {
            entity.deleteSync(recursive: true);
          } else {
            String content = await entity.readAsString();
            content = removeAppMarker(content.split('\n'));
            await entity.writeAsString(content);
          }
        }
      },
      onDirectory: (entity) async {
        if (entity.path.endsWith('pages')) {
          entity.deleteSync(recursive: true);
        }
      },
    );
  }
}
