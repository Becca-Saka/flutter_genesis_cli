import 'package:cli_app/models/firebase_app_details.dart';
import 'package:cli_app/templates/template_options.dart';

enum FlutterAppPlatform {
  ios,
  android,
  web,
  windows,
  macos,
  linux,
}

class FlutterAppDetails {
  final String name;
  final String path;
  final String packageName;
  final List<TemplateOptions> templates;
  final List<FlutterAppPlatform> platforms;
  final FirebaseAppDetails? firebaseAppDetails;
  FlutterAppDetails({
    required this.name,
    required this.path,
    required this.packageName,
    required this.templates,
    required this.platforms,
    required this.firebaseAppDetails,
  });
}
