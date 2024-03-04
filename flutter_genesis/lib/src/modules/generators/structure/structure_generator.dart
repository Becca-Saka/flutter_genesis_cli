import 'package:flutter_genesis/src/common/process/process.dart';
import 'package:flutter_genesis/src/models/flutter_app_details.dart';
import 'package:flutter_genesis/src/modules/generators/yaml/yaml_generator.dart';

class StructureGenerator {
  StructureGenerator._();
  static StructureGenerator get instance => StructureGenerator._();
  final YamlGenerator yamlGen = YamlGenerator();
  final AdireCliProcess process = AdireCliProcess();

  void generateStructure(FlutterAppDetails appDetails) {
    generateBuildConfig(appDetails);
    runBuildRunner();
  }

  void generateBuildConfig(FlutterAppDetails appDetails) =>
      yamlGen.generateBuildConfig(appDetails);

  Future<void> runBuildRunner() async {
    await process.run(
      'dart',
      streamInput: true,
      arguments: [
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ],
    );
  }
}
