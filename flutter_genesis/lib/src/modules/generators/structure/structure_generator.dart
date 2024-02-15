import 'package:cli_app/src/common/process/process.dart';
import 'package:cli_app/src/modules/generators/yaml/yaml_generator.dart';

class StructureGenerator {
  StructureGenerator._();
  static StructureGenerator get instance => StructureGenerator._();
  final YamlGenerator yamlGen = YamlGenerator();
  final AdireCliProcess process = AdireCliProcess();

  void generateStructure(
    String appName,
    String stateManager,
  ) {
    generateBuildConfig(appName, stateManager);
    runBuildRunner();
  }

  void generateBuildConfig(String appName, String stateManager) =>
      yamlGen.generateBuildConfig(appName, stateManager);

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
