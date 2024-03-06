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
