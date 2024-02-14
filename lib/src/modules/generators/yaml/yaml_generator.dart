import 'dart:io';

import 'yaml_writer.dart';

class YamlGenerator {
  final YamlWriter writer = YamlWriter();
  // final AdireCliProcess process = AdireCliProcess();
  void generateBuildConfig(String appName) {
    String yaml = writer.write({
      'targets': {
        '\$default': {
          'builders': {
            'code_generators|copyBuilder': {'enabled': false},
            'code_generators|appBuilder': {
              'enabled': true,
              'generate_for': ['launcher/lib/**'],
              'options': {
                'destinationDirectory': '${appName}/lib',
                'appName': '${appName}'
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
