import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_genesis_cli/src/shared/extensions/map.dart';
import 'package:flutter_genesis_cli/src/shared/models/flutter_app_details.dart';

import 'yaml_writer.dart';

class YamlGenerator {
  final YamlWriter _writer = YamlWriter();
  // final AdireCliProcess process = AdireCliProcess();
  void generateBuildConfig(FlutterAppDetails flutterAppDetails) {
    String appName = flutterAppDetails.name;
    // String path = appName;
    String path = flutterAppDetails.path;
    String subpath = path;
    String yaml = _writer.write({
      'targets': {
        '\$default': {
          'sources': [
            'launcher/lib/**',
            'launcher/test/**',
            '\$package\$',
            'lib/\$lib\$',
          ],
          'builders': {
            'flutter_genesis_generator|appCopierBuilder': {
              'enabled': true,
              'generate_for': [
                'launcher/lib/**',
              ],
              'options': {
                'destinationDirectory': '${subpath}/lib',
                'appName': '${appName}',
              },
            },
            'flutter_genesis_generator|appTestCopierBuilder': {
              'enabled': true,
              'generate_for': ['launcher/test/**'],
              'options': {
                'destinationDirectory': '${subpath}/test',
                'appName': '${appName}',
                'testPath': '${subpath}/test/'
              },
            }
          },
        }
      }
    });

    File file = File('${Directory.current.path}/build.yaml');
    file.createSync();
    file.writeAsStringSync(yaml);
  }

  void generateFlavorizrConfig(FlutterAppDetails flutterAppDetails) {
    // void generateFlavorizrConfig(FlavorModel flavorModel) {
    final flavorModel = flutterAppDetails.flavorModel!;
    Map flavorMaps = {};
    for (var flavor in flavorModel.environmentOptions) {
      String name = flavorModel.name?[flavor] ?? flutterAppDetails.name;
      final id = flavorModel.packageId![flavor];
      final icon = flavorModel.imagePaths?[flavor];
      name = name.toLowerCase();
      //replace space with underscore
      name = name.replaceAll(' ', '_');
      final appMap = {
        'name': name,
        'icon': icon,
      };

      final buildConfigFields = flavorModel.buildConfigFields
          ?.firstWhereOrNull((element) => element.flavor == flavor);
      final resValues = flavorModel.resValues
          ?.firstWhereOrNull((element) => element.flavor == flavor);
      final versionNameSuffix = flavorModel.versionNameSuffix?[flavor];
      final versionCode = flavorModel.versionCode?[flavor];
      final minSdkVersion = flavorModel.minSdkVersion?[flavor];
      final signingConfig = flavorModel.signingConfig?[flavor];

      var platformMap = {
        'app': appMap,
        'android': {
          'applicationId': id,
          'buildConfigFields': buildConfigFields?.toMap(),
          'resValues': resValues?.toMap(),
          'firebase': {
            'config': flavorModel.firebaseConfig?[flavor]?['androidPath'],
          },
          'customConfig': {
            'versionNameSuffix':
                versionNameSuffix != null ? "\"${versionNameSuffix}\"" : null,
            // 'versionNameSuffix': versionNameSuffix,
            'signingConfig': signingConfig,
            'versionCode': versionCode,
            'minSdkVersion': minSdkVersion,
          }
        },
        'ios': {
          'bundleId': id,
          'buildSettings': buildConfigFields?.toMap(),
          'variables': resValues?.toMap(),
          'firebase': {
            'config': flavorModel.firebaseConfig?[flavor]?['iosPath'],
          },
        }
      };
      if (!flutterAppDetails.platforms.contains(FlutterAppPlatform.android)) {
        platformMap.removeWhere((key, value) => key == 'android');
      } else if (!flutterAppDetails.platforms
          .contains(FlutterAppPlatform.ios)) {
        platformMap.removeWhere((key, value) => key == 'ios');
      }

      flavorMaps.addAll({'$flavor': platformMap});
    }
    flavorMaps = flavorMaps.removeNullValues;
    String yaml = _writer.write({'flavors': flavorMaps});
    File file = File('${flutterAppDetails.path}/flavorizr.yaml');
    file.createSync();
    file.writeAsStringSync(yaml);
  }

  void generateLauncherIconConfig(FlutterAppDetails flutterAppDetails) {
    final iconPath = flutterAppDetails.iconPath;
    final platforms = flutterAppDetails.platforms;
    Map<dynamic, dynamic> platformMap = {
      if (platforms.contains(FlutterAppPlatform.android))
        "android": "launcher_icon",
      "ios": platforms.contains(FlutterAppPlatform.ios),
      "image_path": iconPath,
      "min_sdk_android": 21,
      "remove_alpha_ios": true,
      "web": {
        "generate": platforms.contains(FlutterAppPlatform.web),
        "image_path": iconPath,
      },
      "windows": {
        "generate": platforms.contains(FlutterAppPlatform.windows),
        "image_path": iconPath,
      },
      "macos": {
        "generate": platforms.contains(FlutterAppPlatform.macos),
        "image_path": iconPath,
      }
    };

    platformMap = platformMap.removeNullValues;
    String yaml = _writer.write({"flutter_launcher_icons": platformMap});
    File file = File('${flutterAppDetails.path}/flutter_launcher_icons.yaml');
    file.createSync();
    file.writeAsStringSync(yaml);
  }
}
