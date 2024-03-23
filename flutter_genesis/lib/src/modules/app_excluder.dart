import 'dart:io';

import 'package:flutter_genesis/src/models/flutter_app_details.dart';
import 'package:flutter_genesis/src/modules/pattern_replace.dart';
import 'package:path/path.dart';

import 'excludable_code.dart';

void removeCode(FlutterAppDetails appDetails) {
  final basePath = join(appDetails.path, 'lib', 'managers');
  print('removing $basePath');

  //TODO: add test folder back
  _deleteFolder(join(appDetails.path, 'test'));
  modifyCoreFiles(appDetails);
}

void _deleteFolder(path) {
  final folderPath = Directory(path);

  if (folderPath.existsSync()) folderPath.deleteSync(recursive: true);
}

// void _deleteFile(path) {
//   final filePath = File(path);

//   if (filePath.existsSync()) filePath.deleteSync(recursive: true);
// }

Future<void> modifyCoreFiles(FlutterAppDetails appDetails) async {
  print("---Modifying core files---");

  final corepaths = [
    '${appDetails.path}/lib/main.dart',
    '${appDetails.path}/lib/app/app_routes.dart',
  ];
  for (var element in corepaths) {
    final direc = File(element);
    if (direc.existsSync()) {
      final inputContent = direc.readAsStringSync();
      final modifiedContent = modifyExistingFile(inputContent, appDetails.name);
      await direc.writeAsString(modifiedContent);
    }
  }
}

String modifyExistingFile(String inputContent, String appName) {
  final excludable = ExcludableCodes(appName);

  for (var key in excludable.exclude) {
    inputContent = replaceByPattern(
      inputContent,
      oldPattern: key,
      newPattern: '',
    );
  }
  for (var key in excludable.excludeCodesWithReplacement().entries) {
    inputContent = replaceByPattern(
      inputContent,
      oldPattern: key.key,
      newPattern: key.value,
    );
  }

  return inputContent;
}
