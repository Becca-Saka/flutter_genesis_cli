import 'dart:async';

import 'package:build/build.dart';

class CopyBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
        '.txt': ['.copy.txt']
      };

  @override
  Future<FutureOr<void>> build(BuildStep buildStep) async {
    AssetId inputId = buildStep.inputId;
    var copyAssetId = inputId.changeExtension('.copy.txt');
    var contents = await buildStep.readAsString(inputId);

    await buildStep.writeAsString(copyAssetId, '''

------------------------
${DateTime.now()}

------------------------
$contents


''');
  }
}
