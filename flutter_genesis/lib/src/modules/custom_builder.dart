import 'package:build/build.dart';

/// A really simple [Builder], it just makes copies of .txt files!
class CopyBuilder implements Builder {
  @override
  final buildExtensions = const {
    '.txt': ['.txt.copy']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Each `buildStep` has a single input.
    var inputId = buildStep.inputId;

    // Create a new target `AssetId` based on the old one.
    var copy = inputId.addExtension('.copy');
    var contents = await buildStep.readAsString(inputId);

    // Write out the new asset.
    await buildStep.writeAsString(copy, contents);
  }
}
