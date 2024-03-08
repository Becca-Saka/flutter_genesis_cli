// import 'package:flutter_genesis/src/common/logger.dart';
// import 'package:flutter_genesis/src/models/flutter_app_details.dart';
// import 'package:flutter_genesis/src/modules/app_copier.dart';
// import 'package:flutter_genesis/src/modules/app_excluder.dart';
// import 'package:flutter_genesis/src/modules/flutter_app/flutter_app.dart';
// import 'package:flutter_genesis/src/modules/flutter_app/flutter_cli.dart';
// import 'package:flutter_genesis/src/modules/flutter_app/flutter_package_manager.dart';
// import 'package:flutter_genesis/src/templates/domain/firebase/flutter_fire_cli.dart';
// // import 'package:flutter_genesis/src/templates/domain/firebase/flutter_fire_cli.dart';

// Future<void> createApp() async {
//   try {
//     FlutterAppDetails flutterAppDetails = await await FlutterApp().init();
//     // flutterAppDetails = flutterAppDetails.copyWith(path: projectPath);
//     // await FlutterCli.instance.pubGet(projectPath);
//     if (flutterAppDetails.firebaseAppDetails != null) {
//       await FlutterFireCli.instance.initializeFirebase(flutterAppDetails);
//     }
//     await AppCopier().copyFiles(
//       sourcePath: 'lib',
//       appDetails: flutterAppDetails,
//     );
//     AppExcluder().removeCode(flutterAppDetails);
//     // await FlutterPackageManager.getPackages(flutterAppDetails);
//     // StructureGenerator.instance.generateStructure(flutterAppDetails);
//     await FlutterPackageManager.getPackages(flutterAppDetails);
//     await FlutterCli.instance.format(flutterAppDetails.path);
//   } on Exception catch (ed) {
//     e('Error: $ed');
//   }
// }
