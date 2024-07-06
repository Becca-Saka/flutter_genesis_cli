import 'dart:io';

import 'package:flutter_genesis_cli/src/commands/process/process.dart';
import 'package:flutter_genesis_cli/src/modules/flutter_app/flutter_cli.dart';
import 'package:flutter_genesis_cli/src/shared/extensions/lists.dart';
import 'package:flutter_genesis_cli/src/shared/logger.dart';
import 'package:flutter_genesis_cli/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis_cli/src/shared/models/flutter_app_details.dart';
import 'package:flutter_genesis_cli/src/templates/firebase/firebase_package_manager.dart';
import 'package:flutter_genesis_cli/src/templates/flavors/flavor_model.dart';
import 'package:tint/tint.dart';

import 'commands/app_id.dart';
import 'commands/firebase_auth.dart';
import 'commands/options.dart';

class FlutterFireCli {
  FlutterFireCli._();
  static FlutterFireCli get instance => FlutterFireCli._();
  final FlutterGenesisCli process = FlutterGenesisCli();
  List<FirebaseOptions> selectedOptions = [];

  Future<FirebaseAppDetails> getFirebaseAppDetails(
    String appName,
    FlavorModel? flavors,
  ) async {
    String firebaseToken = await getFirebaseCliToken();
    selectedOptions = getOptions();
    FirebaseAppDetails details = FirebaseAppDetails(
      cliToken: firebaseToken,
      selectedOptions: selectedOptions,
    );
    if (useFlavors(flavors)) {
      assert(flavors != null);
      final namesByFlavor = flavors!.name;
      final flavorsEnvironment = flavors.environmentOptions;
      details.flavorConfigs ??= [];
      for (var i = 0; i < flavorsEnvironment.length; i++) {
        final name = namesByFlavor?.entries.elementAt(i).value ?? appName;
        final flavor = flavorsEnvironment[i];
        final packageName = flavors.packageId![flavor]!;
        m('Configuring Firebase project for' + ' $name'.bold() + '-${flavor}');
        final projectId = await getAppId(
          token: firebaseToken,
          name:
              '${name}-${flavor}', //TODO: validate flavor name to prevent cases like AppName(Dev)-dev
          validator: (p0) {
            final valid = details.flavorConfigs!.where((element) =>
                element.projectId == p0 && element.packageName == packageName);

            return valid.isEmpty;
          },
        );

        details.flavorConfigs!.add(FirebaseFlavorConfig(
          flavor: flavor,
          projectId: projectId.$1,
          projectName: projectId.$2,
          packageName: packageName,
        ));
      }
    } else {
      final projectId = await getAppId(
        token: firebaseToken,
        name: appName,
        validator: (_) => true,
      );

      details = details.copyWith(
        projectId: projectId.$1,
        projectName: projectId.$2,
      );
    }

    details = await loadFirebaseOptions(details, selectedOptions);
    return details;
  }

  bool useFlavors(FlavorModel? flavors) {
    if (flavors != null) {
      return process.getConfirmation(
        prompt:
            'Would you like to generate different firebase project for your flavors?',
        defaultValue: false,
      );
    }
    return false;
  }

  List<FirebaseOptions> getOptions() {
    List<FirebaseOptions> options = List.from(FirebaseOptions.values);
    options.remove(FirebaseOptions.core);
    final selectedOptionIndex = process.getMultiSelectInput(
      prompt: 'What firebase options would you like?',
      options: options.names,
    );
    return selectedOptionIndex.map((e) => options[e]).toList();
  }

  Future<void> initializeFirebase(FlutterAppDetails flutterAppDetails) async {
    await FlutterCli.activate('flutterfire_cli', flutterAppDetails.path);

    await _configureCli(flutterAppDetails);
    FirebasePackageManager.getPackages(flutterAppDetails);

    m('FlutterFireCli init done');
  }

  Future<void> _configureCli(FlutterAppDetails flutterAppDetails) async {
    final firebaseAppDetails = flutterAppDetails.firebaseAppDetails;
    if (firebaseAppDetails != null) {
      final dir = Directory(flutterAppDetails.path);
      m('Configuring FlutterFire $dir');
      final export = [
        'export PATH="\$PATH":"<span class="math-inline">HOME/.pub-cache/bin" '
      ];
      await process.run('bash',
          arguments: ['-c', 'dart pub global activate flutterfire_cli'],
          workingDirectory: flutterAppDetails.path);
      await process.run(
        'bash',
        arguments: ['-l', '-c', ...export],
        workingDirectory: flutterAppDetails.path,
      );

      final token = firebaseAppDetails.cliToken;
      final platforms =
          flutterAppDetails.platforms.map((e) => e.name).toList().join(',');
      final flavorModel = flutterAppDetails.flavorModel;
      final flavorConfigs = firebaseAppDetails.flavorConfigs;
      final appPath = flutterAppDetails.path;
      if (flavorModel != null && flavorConfigs != null) {
        for (int i = 0; i < flavorModel.environmentOptions.length; i++) {
          final flavor = flavorModel.environmentOptions[i];
          String args = ' --out=lib/app/src/$flavor/firebase_options.dart';
          args += ' --android-package-name=${flavorModel.packageId![flavor]}';
          args += ' --ios-bundle-id=${flavorModel.packageId![flavor]}';
          final firebaseFlavorConfig =
              flavorConfigs.firstWhere((element) => element.flavor == flavor);

          await _configureFirebaseProject(
            projectId: firebaseFlavorConfig.projectId,
            token: token,
            args: args,
            platforms: platforms,
            path: appPath,
          );

          if (flutterAppDetails.platforms.contains(FlutterAppPlatform.ios)) {
            await _moveFiles(
              appPath: appPath,
              newPath: '${appPath}/ios/Runner/config/${flavor}',
              oldPath: '${appPath}/ios/Runner/GoogleService-Info.plist',
            );

            await _moveFiles(
              appPath: appPath,
              newPath: '${appPath}/ios/Runner/config/${flavor}',
              oldPath: '${appPath}/ios/firebase_app_id_file.json',
            );
          }
          if (flutterAppDetails.platforms
              .contains(FlutterAppPlatform.android)) {
            await _moveFiles(
              appPath: appPath,
              newPath: '${appPath}/android/app/src/${flavor}',
              oldPath: '${appPath}/android/app/google-services.json',
            );
          }
        }
      } else {
        await _configureFirebaseProject(
          projectId: firebaseAppDetails.projectId!,
          token: token,
          args: '',
          platforms: platforms,
          path: appPath,
        );
      }
      m('Configuring done');
    } else {
      m('Firebase project not defined, skipping');
    }
  }

  Future<void> _configureFirebaseProject({
    required String projectId,
    required String token,
    required String args,
    required String platforms,
    required String path,
  }) async {
    String flutterFire = 'flutterfire configure --project=${projectId}';
    flutterFire += args;
    flutterFire += ' --platforms=${platforms} --token ${token}';

    await process.run(
      'bash',
      streamOutput: false,
      arguments: ['-l', '-c', flutterFire],
      showSpinner: true,
      spinnerMessage: (done) =>
          done ? 'Configured Firebase project' : 'Configuring Firebase project',
      workingDirectory: path,
    );
  }

  Future<void> _moveFiles({
    required String newPath,
    required String oldPath,
    required String appPath,
  }) async {
    if (!File(oldPath).existsSync()) {
      return;
    }
    if (!Directory(newPath).existsSync()) {
      Directory(newPath).createSync(recursive: true);
    }
    await process.run(
      'mv',
      arguments: [
        oldPath,
        newPath,
      ],
      workingDirectory: appPath,
      streamOutput: false,
    );
  }
}
