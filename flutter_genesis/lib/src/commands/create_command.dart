import 'package:args/command_runner.dart';
import 'package:flutter_genesis/src/modules/flutter_app/flutter_app.dart';

class CreateApp extends Command {
  @override
  String get description => 'Create a new Flutter app';

  @override
  String get name => 'create';

  @override
  Future<void> run() async {
    FlutterApp app = FlutterApp();
    final flutterAppDetails = await app.init();
    await app.postCreate(flutterAppDetails);
  }
}
