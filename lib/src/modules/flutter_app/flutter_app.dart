import 'dart:io';

import 'package:flutter_genesis_cli/src/commands/process/process.dart';
import 'package:flutter_genesis_cli/src/modules/app_copier.dart';
import 'package:flutter_genesis_cli/src/modules/app_excluder.dart';
import 'package:flutter_genesis_cli/src/modules/flutter_app/flutter_cli.dart';
import 'package:flutter_genesis_cli/src/modules/flutter_app/flutter_package_manager.dart';
import 'package:flutter_genesis_cli/src/modules/generators/json/vscode_launcher_gen.dart';
import 'package:flutter_genesis_cli/src/shared/extensions/lists.dart';
import 'package:flutter_genesis_cli/src/shared/logger.dart';
import 'package:flutter_genesis_cli/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis_cli/src/shared/models/flutter_app_details.dart';
import 'package:flutter_genesis_cli/src/shared/models/template_options.dart';
import 'package:flutter_genesis_cli/src/shared/validators.dart';
import 'package:flutter_genesis_cli/src/templates/firebase/flutter_fire_cli.dart';
import 'package:flutter_genesis_cli/src/templates/flavors/base_flavor_manager.dart';
import 'package:flutter_genesis_cli/src/templates/flavors/flavor_model.dart';
import 'package:path/path.dart';

///Handles the flutter app creation process.
///
///
class FlutterApp {
  FlutterGenesisCli process = FlutterGenesisCli();
  BaseFlavorManager _flavorManager = BaseFlavorManager();
  AppCopier _appCopier = AppCopier();
  Future<FlutterAppDetails> init({
    String? name,
    String? package,
    String? path,
    String? flavor,
  }) async {
    if (name == null) {
      name = _getAppName();
    }

    if (package == null) {
      package = _getPackageName(name);
    }

    if (path == null) {
      path = _getPath();
    }

    final flavors = await _flavorManager.getFlavorInfomation(
      package: package,
      model: flavor != null && flavor.isNotEmpty
          ? FlavorModel(
              environmentOptions:
                  flavor.split(',').map((e) => e.trim()).toList())
          : null,
    );

    // final package = _getPackageName(name);
    // final path = _getPath();
    // final flavors = await _flavorManager.getFlavorInfomation(package);
    final templates = _getTemplateOptions();
    final platforms = _getPlatformOptions();
    final firebaseAppDetails =
        await _loadTemplateOptions(templates, name, flavors);

    final flutterAppDetails = FlutterAppDetails(
      name: name,
      path: path,
      packageName: package,
      templates: templates,
      platforms: platforms,
      firebaseAppDetails: firebaseAppDetails,
      flavorModel: flavors,
    );
    return await _createApp(flutterAppDetails);
  }

  Future<FlutterAppDetails> _createApp(
      FlutterAppDetails flutterAppDetails) async {
    await FlutterCli.create(flutterAppDetails: flutterAppDetails);

    return flutterAppDetails.copyWith(
      path: normalize(flutterAppDetails.path + '/' + flutterAppDetails.name),
    );
  }

  String _getAppName() {
    String? name = process.getInput(
      prompt: 'What should we call your project?',
      validator: (val) => AppValidators.notNullAndNotEmpty(
        val,
        message: 'Name cannot be empty',
      ),
    );
    name = name.toLowerCase();
    //replace space with underscore
    name = name.replaceAll(' ', '_');
    return name;
  }

  String _getPath() {
    String appPath = normalize(Directory.current.parent.path + '/examples');
    final path = process.getInput(
      prompt: 'Where is your project located?',
      defaultValue: appPath,
    );
    if (path.isNotEmpty) {
      appPath = path;
    }

    if (!Directory(appPath).existsSync()) {
      Directory(appPath).createSync(recursive: true);
    }
    return appPath;
  }

  String _getPackageName(String name) {
    final package = process.getInput(
      prompt: 'What is the package name?',
      defaultValue: 'com.example.$name',
      validator: AppValidators.isValidFlutterPackageName,
    );

    return package;
  }

  List<FlutterAppPlatform> _getPlatformOptions() {
    const options = FlutterAppPlatform.values;
    final answerIndexes = process.getMultiSelectInput(
      prompt: 'What platform should your project be initialized for?',
      options: options.names,
      defaultValue: [
        // FlutterAppPlatform.android.name,
        FlutterAppPlatform.ios.name,
      ],
    );
    if (answerIndexes.isEmpty) {
      e('Please select a platform');
      _getPlatformOptions();
    }
    final answers = options
        .where((element) => answerIndexes.contains(options.indexOf(element)))
        .toList();
    m('You selected: ${answers.names.joined}');

    return answers;
  }

  List<TemplateOptions> _getTemplateOptions() {
    const options = TemplateOptions.values;
    final answerIndexes = process.getMultiSelectInput(
      prompt: 'What would you like to initialize?',
      options: options.names,
    );
    final answers = options
        .where((element) => answerIndexes.contains(options.indexOf(element)))
        .toList();
    m('You selected: ${answers.names.joined}');
    return answers;
  }

  Future<FirebaseAppDetails?> _loadTemplateOptions(
    List<TemplateOptions> options,
    String name,
    FlavorModel? flavors,
  ) async {
    if (options.contains(TemplateOptions.firebase)) {
      final firebaseAppDetails =
          await FlutterFireCli.instance.getFirebaseAppDetails(name, flavors);
      return firebaseAppDetails;
    }
    return null;
  }

  Future<void> postCreate(FlutterAppDetails flutterAppDetails) async {
    if (flutterAppDetails.firebaseAppDetails != null) {
      await FlutterFireCli.instance.initializeFirebase(flutterAppDetails);
    }
    if (flutterAppDetails.flavorModel != null) {
      await _flavorManager.createFlavor(flutterAppDetails);
      await _flavorManager.modifyNewDestinationFiles(flutterAppDetails);
    }

    await _copyFiles(flutterAppDetails);
    await process.delayProcess(3, 'Cleaning up');
    await _removeCode(flutterAppDetails);
    await _appCopier.cleanUpComments(appDetails: flutterAppDetails);
    await VsCodeLauncherGenerator().create(flutterAppDetails);
    await _cleanUp(flutterAppDetails);
  }

  Future<void> _copyFiles(FlutterAppDetails flutterAppDetails) async =>
      await _appCopier.copyFiles(flutterAppDetails);

  Future<void> _removeCode(FlutterAppDetails flutterAppDetails) async =>
      await removeCode(flutterAppDetails);

  Future<void> _cleanUp(FlutterAppDetails flutterAppDetails) async {
    await FlutterPackageManager.getPackages(flutterAppDetails);
    await FlutterCli.format(flutterAppDetails.path);
  }
}
