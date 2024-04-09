import 'package:args/command_runner.dart';
import 'package:flutter_genesis_cli/src/commands/create_command.dart';

const String version = '0.0.1';

void main(List<String> arguments) {
  CommandRunner(
    "flutter genesis",
    "the CLI for your app's genesis",
  )
    ..addCommand(CreateApp())
    ..run(arguments);
}
