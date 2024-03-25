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

String removeLinesBetweenMarkers(List<String> inputContent, String marker) {
  var inBlock = false;
  String startMarker = '// START REMOVE BLOCK: $marker';
  String endMarker = '// END REMOVE BLOCK: $marker';
  var newLines = <String>[];
  for (var line in inputContent) {
    if (line.contains(endMarker)) {
      inBlock = false;
    }
    if (!inBlock && !line.contains(startMarker) && !line.contains(endMarker)) {
      newLines.add(line);
    }
    if (line.contains(startMarker)) {
      inBlock = true;
    }
  }

  return newLines.join('\n');
}

String removeCommentBetweenMarkers(List<String> inputContent, String marker) {
  var inBlock = false;
  String startMarker = '// START REMOVE COMMENT: $marker';
  String endMarker = '// END REMOVE COMMENT: $marker';
  var newLines = <String>[];
  for (var line in inputContent) {
    if (line.contains(endMarker)) {
      inBlock = false;
    }
    if (inBlock) {
      // print(line);
      // int index = inputContent.indexOf(line);
      line = line.replaceAll('//', '');

      // inputContent[index] = line;
    }
    if (!line.contains(startMarker) && !line.contains(endMarker)) {
      newLines.add(line);
    }
    if (line.contains(startMarker)) {
      inBlock = true;
    }
  }

  return newLines.join('\n');
}
