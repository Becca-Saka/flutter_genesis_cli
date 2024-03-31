import 'dart:io';

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
