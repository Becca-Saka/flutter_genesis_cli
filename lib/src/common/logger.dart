import 'package:logger/logger.dart';
import 'package:tint/tint.dart';

///Helps to beautify the CLI
void m(String message) {
  print('💡 ${message}'.white());
}

void e(String message) {
  print('✘ ${message}'.red());
}

Logger get losgger => Logger(
      filter: MyFilter(),
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: false,
      ),
    );

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}
