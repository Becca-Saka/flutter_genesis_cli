import 'package:path/path.dart';

extension StringExtension on String {
  String baseFolder(int length) {
    String relativePath = this.substring(length);

    final joinPart = split(relativePath);

    final joinPartSplited = List<String>.from(joinPart)..removeLast();

    relativePath = joinAll(joinPartSplited);

    return relativePath;
  }
}
