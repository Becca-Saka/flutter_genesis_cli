import 'package:tint/tint.dart';

///Helps to beautify the CLI
void m(String message) {
  print('💡 ${message}'.white());
}

void e(String message) {
  print('✘ ${message}'.red());
}
