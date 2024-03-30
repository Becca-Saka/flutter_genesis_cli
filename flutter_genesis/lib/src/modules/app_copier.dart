import 'dart:io';

import 'package:flutter_genesis/src/shared/extensions/lists.dart';
import 'package:flutter_genesis/src/shared/extensions/string.dart';
import 'package:flutter_genesis/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';
import 'package:path/path.dart';

import 'pattern_replace.dart';

class AppCopier {
  late FlutterAppDetails flutterAppDetails;
  Future<void> copyFiles(FlutterAppDetails appDetails) async {
    flutterAppDetails = appDetails;
    await readFiles(
      dirPath: 'launcher/lib',
      onFile: (entity, dir) async {
        final destinationFile =
            _getNewPath(dirPath: dir.path, entityPath: entity.path);
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

  Future<void> readFiles({
    required String dirPath,
    Function(File, Directory)? onFile,
    Function(Directory)? onDirectory,
  }) async {
    Directory dir = Directory(dirPath);
    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        onFile?.call(entity, dir);
      } else if (entity is Directory) {
        onDirectory?.call(entity);
      }
    }
  }

  File _getNewPath({required String dirPath, required String entityPath}) {
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

  //--
  Future<void> modifyNewDestinationFiles(
      {required FlutterAppDetails appDetails}) async {
    flutterAppDetails = appDetails;
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
  ) async {
    String destinationPath = '';
    final newLines = <String>[];
    if (flutterAppDetails.flavorModel?.environmentOptions != null) {
      if (flutterAppDetails.firebaseAppDetails?.flavorConfigs != null) {
        content = _addFirebaseFlavorConfig(baseName, content);
      }
      destinationPath = _moveFlavorFiles(
        baseName,
        content,
        newLines,
        destinationPath,
        destinationDirectory,
        relativePath,
      );
    }
    if (destinationPath.isEmpty) {
      destinationPath = '$destinationDirectory$relativePath';
    }
    if (newLines.isNotEmpty) {
      content = newLines.join('\n');
    }
    return (destinationPath, content);
  }

  String _moveFlavorFiles(
      String baseName,
      String content,
      List<String> newLines,
      String destinationPath,
      String destinationDirectory,
      String relativePath) {
    for (var flavor in flutterAppDetails.flavorModel!.environmentOptions) {
      final flavorPath = 'main_${flavor.toLowerCase()}.dart';

      if (baseName.endsWith(flavorPath)) {
        print('-------found: $flavorPath-----');

        final lines = content.split('\n');
        for (var line in lines) {
          line = replaceByPattern(
            line,
            oldPattern: "import '",
            newPattern: "import 'package:${flutterAppDetails.name}/",
          );
          newLines.add(line);
        }
        // if (lines.contains(""))
        // File oldPath = new File('$destinationDirectory$relativePath');

        // await oldPath.delete(recursive: true);
        destinationPath = '$destinationDirectory/app/src$relativePath';
      }
    }
    return destinationPath;
  }

  String _addFirebaseFlavorConfig(String baseName, String content) {
    if (baseName.endsWith('flavors.dart')) {
      final coreImport = 'import \'package:flutter_core/flutter_core.dart\';';
      content = coreImport + content;
      content = flutterAppDetails.flavorModel!.environmentOptions
              .map((flavor) =>
                  "import 'package:${flutterAppDetails.name}/src/$flavor/firebase_options_$flavor.dart' as $flavor;")
              .join('\n') +
          content;
      final lines = content.split('\n');

      String addedContent = '''
           Future<void> initializeFirebaseApp() async {
      final firebaseOptions = switch (appFlavor) {
      ${flutterAppDetails.flavorModel!.environmentOptions.map((flavor) => ' Flavor.$flavor => $flavor.DefaultFirebaseOptions.currentPlatform,').join('\n')}
      null => ${flutterAppDetails.flavorModel!.environmentOptions.first}.DefaultFirebaseOptions.currentPlatform,
    };
    await Firebase.initializeApp(options: firebaseOptions);
          }
          ''';

      lines[lines.lastIndexOf('}') - 1] += '\n' + addedContent;
      content = lines.join('\n');
    }
    return content;
  }

  Future<void> cleanUpComments({
    required FlutterAppDetails appDetails,
  }) async {
    flutterAppDetails = appDetails;
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
          }
          // if (entity.path.endsWith('lib/app.dart')) {
          //   entity.deleteSync(recursive: true);
          // }
          else {
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
