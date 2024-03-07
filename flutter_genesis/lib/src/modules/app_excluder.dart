import 'dart:io';

import 'package:flutter_genesis/src/models/flutter_app_details.dart';
import 'package:flutter_genesis/src/modules/pattern_replace.dart';
import 'package:path/path.dart';

import 'excludable_code.dart';

class AppExcluder {
  void removeCode(FlutterAppDetails appDetails) {
    final basePath = join(appDetails.path, 'lib', 'managers');
    print('removing $basePath');
    _removeStateManagers(appDetails, basePath);

    //TODO: add test folder back
    _deleteFolder(join(appDetails.path, 'test'));
    modifyCoreFiles(appDetails);
  }

  void _removeStateManagers(FlutterAppDetails appDetails, String basePath) {
    if (appDetails.stateManager == StateManager.bloc) {
      print('State manager is bloc');
      _deleteFolder(join(basePath, 'provider'));
      _deleteFolder(join(basePath, 'setstate'));
    } else if (appDetails.stateManager == StateManager.provider) {
      print('State manager is provider');
      _deleteFolder(join(basePath, 'bloc'));
      _deleteFolder(join(basePath, 'setstate'));
    } else if (appDetails.stateManager == StateManager.setstate) {
      print('State manager is provider');
      _deleteFolder(join(basePath, 'bloc'));
      _deleteFolder(join(basePath, 'provider'));
    }
  }

  void _deleteFolder(path) {
    final folderPath = Directory(path);

    if (folderPath.existsSync()) folderPath.deleteSync(recursive: true);
  }

  void _deleteFile(path) {
    final filePath = File(path);

    if (filePath.existsSync()) filePath.deleteSync(recursive: true);
  }

  Future<void> modifyCoreFiles(FlutterAppDetails appDetails) async {
    print("---Modifying core files---");

    final corepaths = [
      '${appDetails.path}/lib/main.dart',
      '${appDetails.path}/lib/app/app_routes.dart',
    ];
    for (var element in corepaths) {
      final direc = File(element);
      if (direc.existsSync()) {
        print("--$element  exists---");
        final inputContent = direc.readAsStringSync();
        final modifiedContent =
            modifyExistingFile(inputContent, appDetails.name);
        await direc.writeAsString(modifiedContent);
      }
    }
  }

  String modifyExistingFile(String inputContent, String appName) {
    final excludable = ExcludableCodes(appName);
    for (var key in excludable.exclude) {
      print("--removing $key---");
      inputContent = replaceByPattern(
        inputContent,
        oldPattern: key,
        newPattern: '',
      );
      print("--------------------------");
    }
    for (var key in excludable.excludeCodesWithReplacement().entries) {
      print("--removing $key---");
      inputContent = replaceByPattern(
        inputContent,
        oldPattern: key.key,
        newPattern: key.value,
      );
      print("--------------------------");
    }
    return inputContent;
  }
}