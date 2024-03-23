import 'package:args/command_runner.dart';
import 'package:flutter_genesis/src/modules/app_copier.dart';
import 'package:flutter_genesis/src/modules/app_excluder.dart';
import 'package:flutter_genesis/src/modules/flutter_app/flutter_app.dart';
import 'package:flutter_genesis/src/modules/flutter_app/flutter_cli.dart';
import 'package:flutter_genesis/src/modules/flutter_app/flutter_package_manager.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';
import 'package:flutter_genesis/src/templates/firebase/flutter_fire_cli.dart';

class CreateApp extends Command {
  @override
  String get description => 'Create a new Flutter app';

  @override
  String get name => 'create';

  @override
  Future<void> run() async {
    FlutterApp app = FlutterApp();
    FlutterAppDetails flutterAppDetails = await app.init();
    if (flutterAppDetails.firebaseAppDetails != null) {
      await FlutterFireCli.instance.initializeFirebase(flutterAppDetails);
    }
    await _copyFiles(flutterAppDetails);
    _removeCode(flutterAppDetails);
    _postCreate(flutterAppDetails);
  }

  Future<void> _copyFiles(FlutterAppDetails flutterAppDetails) async {
    await copyFiles(sourcePath: 'lib', appDetails: flutterAppDetails);
  }

  void _removeCode(FlutterAppDetails flutterAppDetails) {
    removeCode(flutterAppDetails);
  }

  Future<void> _postCreate(FlutterAppDetails flutterAppDetails) async {
    await FlutterPackageManager.getPackages(flutterAppDetails);
    await FlutterCli.format(flutterAppDetails.path);
  }
}
