import 'package:args/command_runner.dart';
import 'package:flutter_genesis/src/commands/create_command.dart';

const String version = '0.0.1';

// Future<void> main() async => createApp();

void main(List<String> arguments) {
  // print(Directory.current);
  CommandRunner(
    "flutter genesis",
    "the CLI for your app's genesis",
  )
    ..addCommand(CreateApp())
    ..run(arguments);
}

// void main(List<String> arguments) {
//   File file = File(
//       "/Users/becca/StudioProjects/flutter/Work/Adire/flutter_genesis_cli/build_script_gen.sh");
//   if (!file.existsSync()) {
//     file.createSync();
//   }
//   final tempEnv = ['dev', 'staging', 'prod'];
//   String contents = '''
// # Name of the resource we're selectively copying
// FIREBASE_APP_ID_FILE=firebase_app_id_file.json

// # Get references to dev and prod versions of firebase_app_id_file.json
// # NOTE: These should only live on the file system and should NOT be part of the target (since we'll be adding them to the target manually)

// ''';
//   final fileName = _writeInLoop(
//     // contents: contents,
//     tempEnv: tempEnv,
//     line: (flavor) {
//       final flavorUppperCase = flavor.toUpperCase();
//       return "FIREBASE_APP_ID_FILE_$flavorUppperCase=\${PROJECT_DIR}/\${TARGET_NAME}/config/$flavor/\${FIREBASE_APP_ID_FILE}\n";
//     },
//   );
//   contents += fileName;
//   // for (var flavor in tempEnv) {
//   //   final flavorUppperCase = flavor.toUpperCase();
//   //   contents +=
//   //       "FIREBASE_APP_ID_FILE_$flavorUppperCase=\${PROJECT_DIR}/\${TARGET_NAME}/config/$flavor/\${FIREBASE_APP_ID_FILE}\n";
//   // }

//   contents += '''
// echo \${PROJECT_DIR}
// echo \${TARGET_NAME}


// ''';
//   final fileSearch = _writeInLoop(
//     // contents: contents,
//     tempEnv: tempEnv,
//     line: (flavor) {
//       final flavorUppperCase = flavor.toUpperCase();
//       return '''

// # Make sure the $flavor version of firebase_app_id_file.json exists
// echo "Looking for \${FIREBASE_APP_ID_FILE} in \${FIREBASE_APP_ID_FILE_$flavorUppperCase}"
// if [ ! -f \$FIREBASE_APP_ID_FILE_$flavorUppperCase ]
// then
//     echo "No $flavor firebase_app_id_file.json found. Please ensure it's in the proper directory."
//     exit 1
// fi

// ''';
//     },
//   );
//   contents += fileSearch;

//   contents += '''
// # Get a reference to the destination location for firebase_app_id_file.json
// FILE_DESTINATION=\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app
// echo "Will copy \${FIREBASE_APP_ID_FILE} to final destination: \${FILE_DESTINATION}"

// # Copy over the correct firebase_app_id_file.json for the current build configuration
// ''';
//   final fileCopier = _writeIfElseInLoop(
//     tempEnv: tempEnv,
//     line: (flavor, conditional) {
//       return '''
// $conditional [ "\${CONFIGURATION}" == "Debug-$flavor" ] || [ "\${CONFIGURATION}" == "Release-$flavor" ] || [ "\${CONFIGURATION}" == "Profile-$flavor" ]
// then
//     echo "Using \${FIREBASE_APP_ID_FILE_PROD}"
//     cp "\${FIREBASE_APP_ID_FILE_PROD}" "\${FILE_DESTINATION}"

// ''';
//     },
//   );
//   contents += fileCopier;
//   contents += '''
// else
//     echo "Error: invalid configuration specified: \${CONFIGURATION}"
// fi
// ''';
//   file.writeAsString(contents);
// }

// String _writeIfElseInLoop({
//   required List<String> tempEnv,
//   // required String contents,
//   required String Function(String, String) line,
// }) {
//   String contents = "";
//   for (var flavor in tempEnv) {
//     final index = tempEnv.indexOf(flavor);
//     String condtionalBlock;

//     if (index == 0) {
//       condtionalBlock = "if";
//     } else {
//       condtionalBlock = "elif";
//     }

//     contents += line(flavor, condtionalBlock);
//   }
//   return contents;
// }

// String _writeInLoop({
//   required List<String> tempEnv,
//   // required String contents,
//   required String Function(String) line,
// }) {
//   String contents = "";
//   for (var flavor in tempEnv) {
//     contents += line(flavor);
//   }
//   return contents;
// }
