import 'dart:io';

import 'package:flutter_genesis/src/commands/process/process.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';

class FirebaseJsonScriptGenerator {
  late FlutterAppDetails appDetails;
  Future<void> create(FlutterAppDetails app) async {
    if (app.flavorModel != null) {
      appDetails = app;

      final file = await _generateBuildScript();
      print('file ${file.path}');
      final rubyScript = await _buildRubyScript(file);
      print('rubyScript ${rubyScript.path}');
      await _runRubyScript(rubyScript);
      _cleanUp();
    }
  }

  Future<void> _runRubyScript(File file) async {
    await FlutterGenesisCli().run(
      'ruby',
      arguments: [file.path],
      streamOutput: false,
    );
  }

  Future<File> _buildRubyScript(File file) async {
    final rubyFile = File('${Directory.current.path}/build_script_attacher.rb');
    final contents = await rubyFile.readAsLines();
    var newLines = <String>[];
    for (var line in contents) {
      if (line.contains('source_script_path =')) {
        final path = "source_script_path = '${file.path}'";
        line = path;
      }

      if (line.contains('project = Xcodeproj::Project.open')) {
        final path =
            'project = Xcodeproj::Project.open "${appDetails.path}/ios/Runner.xcodeproj"';
        line = path;
      }
      newLines.add(line);
    }
    File newDestination =
        File(appDetails.path + '/.flutter_genesis/build_script_attach.rb');
    await newDestination.create(recursive: true);
    return await newDestination.writeAsString(newLines.join('\n'));
  }

  Future<File> _generateBuildScript() async {
    File file = File("${appDetails.path}/.flutter_genesis/build_script.sh");
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    final flavors = appDetails.flavorModel!.environmentOptions;

    String contents = '''
# Name of the resource we're selectively copying
FIREBASE_APP_ID_FILE=firebase_app_id_file.json

# Get references to dev and prod versions of firebase_app_id_file.json
# NOTE: These should only live on the file system and should NOT be part of the target (since we'll be adding them to the target manually)

''';
    final fileName = _writeInLoop(
      tempEnv: flavors,
      line: (flavor) {
        final flavorUppperCase = flavor.toUpperCase();
        return "FIREBASE_APP_ID_FILE_$flavorUppperCase=\${PROJECT_DIR}/\${TARGET_NAME}/config/$flavor/\${FIREBASE_APP_ID_FILE}\n";
      },
    );
    contents += fileName;

    contents += '''
echo \${PROJECT_DIR}
echo \${TARGET_NAME}


''';
    final fileSearch = _writeInLoop(
      tempEnv: flavors,
      line: (flavor) {
        final flavorUppperCase = flavor.toUpperCase();
        return '''

# Make sure the $flavor version of firebase_app_id_file.json exists
echo "Looking for \${FIREBASE_APP_ID_FILE} in \${FIREBASE_APP_ID_FILE_$flavorUppperCase}"
if [ ! -f \$FIREBASE_APP_ID_FILE_$flavorUppperCase ]
then
    echo "No $flavor firebase_app_id_file.json found. Please ensure it's in the proper directory."
    exit 1
fi

''';
      },
    );
    contents += fileSearch;

    contents += '''
# Get a reference to the destination location for firebase_app_id_file.json
FILE_DESTINATION=\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app
echo "Will copy \${FIREBASE_APP_ID_FILE} to final destination: \${FILE_DESTINATION}"

# Copy over the correct firebase_app_id_file.json for the current build configuration
''';
    final fileCopier = _writeIfElseInLoop(
      tempEnv: flavors,
      line: (flavor, conditional) {
        return '''
$conditional [ "\${CONFIGURATION}" == "Debug-$flavor" ] || [ "\${CONFIGURATION}" == "Release-$flavor" ] || [ "\${CONFIGURATION}" == "Profile-$flavor" ]
then
    echo "Using \${FIREBASE_APP_ID_FILE_PROD}"
    cp "\${FIREBASE_APP_ID_FILE_PROD}" "\${FILE_DESTINATION}"

''';
      },
    );
    contents += fileCopier;
    contents += '''
else
    echo "Error: invalid configuration specified: \${CONFIGURATION}"
fi
''';
    return await file.writeAsString(contents);
  }

  String _writeIfElseInLoop({
    required List<String> tempEnv,
    required String Function(String, String) line,
  }) {
    String contents = "";
    for (var flavor in tempEnv) {
      final index = tempEnv.indexOf(flavor);
      String condtionalBlock;

      if (index == 0) {
        condtionalBlock = "if";
      } else {
        condtionalBlock = "elif";
      }

      contents += line(flavor, condtionalBlock);
    }
    return contents;
  }

  String _writeInLoop({
    required List<String> tempEnv,
    required String Function(String) line,
  }) {
    String contents = "";
    for (var flavor in tempEnv) {
      contents += line(flavor);
    }
    return contents;
  }

  void _cleanUp() {
    final dir = Directory(appDetails.path + '/.flutter_genesis');
    dir.deleteSync(recursive: true);
  }
}
