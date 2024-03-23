import 'package:flutter_genesis/src/models/firebase_app_details.dart';
import 'package:flutter_genesis/src/templates/template_options.dart';

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

  FlutterAppDetails copyWith({
    String? name,
    String? path,
    String? packageName,
    List<TemplateOptions>? templates,
    List<FlutterAppPlatform>? platforms,
    FirebaseAppDetails? firebaseAppDetails,
  }) {
    return FlutterAppDetails(
      name: name ?? this.name,
      path: path ?? this.path,
      packageName: packageName ?? this.packageName,
      templates: templates ?? this.templates,
      platforms: platforms ?? this.platforms,
      firebaseAppDetails: firebaseAppDetails ?? this.firebaseAppDetails,
    );
  }
}
