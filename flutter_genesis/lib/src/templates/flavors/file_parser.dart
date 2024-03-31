import 'dart:io';

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
