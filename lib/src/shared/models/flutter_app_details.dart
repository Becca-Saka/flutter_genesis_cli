import 'package:flutter_genesis_cli/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis_cli/src/shared/models/template_options.dart';
import 'package:flutter_genesis_cli/src/templates/flavors/flavor_model.dart';

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
  final String? iconPath;
  final String packageName;
  final List<TemplateOptions> templates;
  final List<FlutterAppPlatform> platforms;
  final FirebaseAppDetails? firebaseAppDetails;
  final FlavorModel? flavorModel;
  bool get copyTempFiles =>
      flavorModel != null || templates.isNotEmpty || firebaseAppDetails != null;
  FlutterAppDetails({
    required this.name,
    required this.path,
    required this.iconPath,
    required this.packageName,
    required this.templates,
    required this.platforms,
    required this.firebaseAppDetails,
    required this.flavorModel,
  });

  FlutterAppDetails copyWith({
    String? name,
    String? path,
    String? iconPath,
    String? packageName,
    List<TemplateOptions>? templates,
    List<FlutterAppPlatform>? platforms,
    FirebaseAppDetails? firebaseAppDetails,
    FlavorModel? flavorModel,
  }) {
    return FlutterAppDetails(
      name: name ?? this.name,
      path: path ?? this.path,
      iconPath: iconPath ?? this.iconPath,
      packageName: packageName ?? this.packageName,
      templates: templates ?? this.templates,
      platforms: platforms ?? this.platforms,
      firebaseAppDetails: firebaseAppDetails ?? this.firebaseAppDetails,
      flavorModel: flavorModel ?? this.flavorModel,
    );
  }
}
