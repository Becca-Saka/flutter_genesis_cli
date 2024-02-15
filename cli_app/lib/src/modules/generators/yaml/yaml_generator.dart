import 'dart:io';

import 'yaml_writer.dart';

class YamlGenerator {
  final YamlWriter writer = YamlWriter();
  // final AdireCliProcess process = AdireCliProcess();
  void generateBuildConfig(
    String appName,
    String stateManager,
  ) {
    String yaml = writer.write({
      'targets': {
        '\$default': {
          'builders': {
            'code_generators|copyBuilder': {'enabled': false},
            'code_generators|appCopierBuilder': {
              'enabled': true,
              'generate_for': ['launcher/lib/**'],
              'options': {
                'destinationDirectory': '${appName}/lib',
                'appName': '${appName}',
                'stateManager': '$stateManager',
              },
            }
          },
          'sources': ['launcher/**', 'lib/**']
        }
      }
    });

    File file = File('${Directory.current.path}/build.yaml');
    file.createSync();
    file.writeAsStringSync(yaml);
  }
}