import 'dart:io';

import 'package:flutter_genesis_cli/src/modules/pattern_replace.dart';

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

void addCodeToEndOfFile(String filePath, String codeToAdd) {
  var file = File(filePath);
  var lines = file.readAsLinesSync();
  var lastIndex = lines.lastIndexWhere((line) => line.trim().endsWith('}'));

  if (lastIndex != -1) {
    lines.insert(lastIndex, codeToAdd);
    file.writeAsStringSync(lines.join('\n'));
  } else {
    throw Exception("File does not contain a closing '}'");
  }
}

void addCodeToStartOfFile(String filePath, String codeToAdd) {
  var file = File(filePath);
  var lines = file.readAsLinesSync();
  lines = _appendAtStart(lines, codeToAdd);
  file.writeAsStringSync(lines.join('\n'));
}

String addCodeToStartOfFileContent(
  String codeToAdd,
  String content,
) {
  var lines = content.split('\n');
  lines = _appendAtStart(lines, codeToAdd);

  return lines.join('\n');
}

List<String> _appendAtStart(
  List<String> lines,
  String codeToAdd,
) {
  int firstNonWhitespaceIndex =
      lines.indexWhere((line) => line.trim().isNotEmpty);

  if (firstNonWhitespaceIndex != -1) {
    lines.insert(firstNonWhitespaceIndex, codeToAdd);

    return lines;
  } else {
    throw Exception("File is empty or contains only whitespace");
  }
}

void addCodeNearLineInFile({
  File? file,
  String? filePath,
  String? codeToAddBelow,
  String? codeToAddAbove,
  required String condition,
}) {
  assert(file != null || filePath != null);

  File newFile;

  if (file != null) {
    newFile = file;
  } else {
    newFile = File(filePath!);
  }

  var lines = newFile.readAsLinesSync();
  lines = _appendCode(lines, codeToAddBelow, codeToAddAbove, condition);

  newFile.writeAsStringSync(lines.join('\n'));
}

String addCodeNearLineInContent({
  required String content,
  String? codeToAddBelow,
  String? codeToAddAbove,
  required String condition,
}) {
  var lines = content.split('\n');
  lines = _appendCode(lines, codeToAddBelow, codeToAddAbove, condition);

  return lines.join('\n');
}

List<String> _appendCode(
  List<String> lines,
  String? codeToAddBelow,
  String? codeToAddAbove,
  String condition,
) {
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains(condition)) {
      if (codeToAddBelow != null && codeToAddBelow.isNotEmpty) {
        lines.insert(i + 1, codeToAddBelow);
      }
      if (codeToAddAbove != null && codeToAddAbove.isNotEmpty) {
        lines.insert(i, codeToAddAbove);
      }
      break;
    }
  }
  return lines;
}

String writeInLoop({
  required List<String> tempEnv,
  required String Function(String) line,
}) {
  String contents = "";
  for (var flavor in tempEnv) {
    contents += line(flavor);
  }
  return contents;
}

Future<String> mergeTwoFiles({
  required String firstFilePath,
  required String secondFilePath,
  required String newClassName,
  required List<String> flags,
}) async {
  var file1 = File(firstFilePath);
  var file2 = File(secondFilePath);
  var file1Content = await file1.readAsString();
  var file2Content = await file2.readAsString();

  List<String> file1Lines = file1Content.split('\n');
  List<String> file2Lines = file2Content.split('\n');

  // Extracting imports from each file
  List<String> file1Imports = [];
  String file1Variables = copyLinesBetweenMarkers(file1Lines, 'variable');
  List<String> file2Imports = [];
  String file2Variables = copyLinesBetweenMarkers(file2Lines, 'variable');

  for (String line in file1Lines) {
    if (line.trimLeft().startsWith('import ')) {
      file1Imports.add(line);
    }
  }
  for (String line in file2Lines) {
    if (line.trimLeft().startsWith('import ')) {
      file2Imports.add(line);
    }
  }

  String file1ClassBody = _extractClassBody(
    content: file1Content,
    flags: flags,
    excludeLine: file1Variables.split('\n'),
  );
  String file2ClassBody = _extractClassBody(
    content: file2Content,
    flags: flags,
    excludeLine: file2Variables.split('\n'),
  );

  // Merging class bodies
  String mergedClassBody =
      file1ClassBody.trim() + '\n\n' + file2ClassBody.trim();

  // Merging imports, class definition, and class bodies
  final mergedImports = file1Imports + file2Imports;
  final variables = file1Variables + '\n' + file2Variables;
  String mergedContent = mergedImports.join('\n') +
      '\n\n' +
      'class $newClassName {${variables}\n\n$mergedClassBody\n}';

  return mergedContent;
}

String _extractClassBody({
  required String content,
  required List<String> flags,
  required List<String> excludeLine,
}) {
  String classBody = content.split('class ')[1];
  classBody = classBody.substring(classBody.indexOf('{') + 1);
  classBody = classBody.substring(0, classBody.lastIndexOf('}'));
  List<String> newLines = [];

  for (var line in classBody.split('\n')) {
    if (!excludeLine.contains(line)) {
      newLines.add(line);
    }
  }
  classBody = newLines.join('\n');
  newLines = [];
  for (var flag in flags) {
    final newBody = copyLinesBetweenMarkers(classBody.split('\n'), flag);
    newLines.addAll(newBody.split('\n'));
  }

  return newLines.join('\n');
}
