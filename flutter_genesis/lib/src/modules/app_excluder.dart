import 'dart:io';

import 'package:flutter_genesis/src/modules/pattern_replace.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';
import 'package:path/path.dart';

Future<void> removeCode(FlutterAppDetails appDetails) async {
  // final basePath = join(appDetails.path, 'lib', 'managers');
  // print('removing $basePath');

  //TODO: add test folder back
  _deleteFolder(join(appDetails.path, 'test'));
  // _deleteFolder(join(appDetails.path, 'lib/ui'));
  if (appDetails.firebaseAppDetails == null) {
    // await modifyCoreFiles(appDetails);
  }
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
  inputContent = removeLinesBetweenMarkers(
    inputContent.split('\n'),
    'noAuth',
  );
  inputContent = removeCommentBetweenMarkers(
    inputContent.split('\n'),
    'noAuth',
  );

  return inputContent;
}
