import 'package:cli_app/src/common/process/process.dart';
import 'package:cli_app/src/modules/generators/yaml/yaml_generator.dart';

class StructureGenerator {
  StructureGenerator._();
  static StructureGenerator get instance => StructureGenerator._();
  final YamlGenerator yamlGen = YamlGenerator();
  final AdireCliProcess process = AdireCliProcess();

  void generateStructure(String appName) {
    generateBuildConfig(appName);
    runBuildRunner();
  }

  void generateBuildConfig(String appName) =>
      yamlGen.generateBuildConfig(appName);

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
