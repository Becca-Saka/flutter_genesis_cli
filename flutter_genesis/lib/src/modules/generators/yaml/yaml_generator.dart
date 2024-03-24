import 'dart:io';

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
    String appName = flutterAppDetails.name;
    // String path = appName;
    String path = flutterAppDetails.path;
    String subpath = path;
    //   flavors:
    // apple:
    //   app:
    //     name: "Apple App"

    //   android:
    //     applicationId: "com.example.apple"
    //   ios:
    //     bundleId: "com.example.apple"
    //   macos:
    //     bundleId: "com.example.apple"
    // banana:
    //   app:
    //     name: "Banana App"

    //   android:
    //     applicationId: "com.example.banana"
    //   ios:
    //     bundleId: "com.example.banana"
    //   macos:
    //     bundleId: "com.example.banana"
    Map<String, String> map = {};
    String yaml = _writer.write({
      'flavors': {
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
}
