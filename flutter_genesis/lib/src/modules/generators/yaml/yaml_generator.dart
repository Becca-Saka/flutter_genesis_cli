import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_genesis/src/shared/models/flutter_app_details.dart';

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
    final flavorModel = flutterAppDetails.flavorModel;

    final flavorMaps = {};
    for (var flavor in flavorModel!.environmentOptions) {
      String name = flavorModel.name![flavor]!;
      final id = flavorModel.packageId![flavor];
      final icon = flavorModel.imagePaths?[flavor];
      name = name.toLowerCase();
      //replace space with underscore
      name = name.replaceAll(' ', '_');
      final appMap = {
        'app': {
          'name': name,
          'icon': icon,
        }
      };
      appMap.entries.first.value.removeWhere((key, value) => value == null);

      final buildConfigFields = flavorModel.buildConfigFields
          ?.firstWhereOrNull((element) => element.flavor == flavor);
      final resValues = flavorModel.resValues
          ?.firstWhereOrNull((element) => element.flavor == flavor);
      final versionNameSuffix = flavorModel.versionNameSuffix?[flavor];
      final versionCode = flavorModel.versionCode?[flavor];
      final minSdkVersion = flavorModel.minSdkVersion?[flavor];
      // final signingConfig = flavorModel.signingConfig?[flavor];//TODO: ask for signingConfig

      final platformMap = {
        'app': appMap,
        'android': {
          'applicationId': id,
          'buildConfigFields': buildConfigFields?.toMap(),
          'resValues': resValues?.toMap(),
          'customConfig': {
            'versionNameSuffix': versionNameSuffix,
            // 'signingConfig': versionNameSuffix,
            'versionCode': versionCode,
            'minSdkVersion': minSdkVersion,
          }
        },
        'ios': {
          'bundleId': id,
          'buildSettings': buildConfigFields?.toMap(),
          'variables': resValues?.toMap(),
        }
      };
      flavorMaps.addAll({
        '$flavor': platformMap,
      });
    }
    String yaml = _writer.write({'flavors': flavorMaps});

    File file = File('${Directory.current.path}/build.yaml');
    file.createSync();
    file.writeAsStringSync(yaml);
  }
}
