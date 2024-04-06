class FlavorModel {
  Map<String, String>? name;
  Map<String, String>? packageId;
  Map<String, String>? imagePaths;
  Map<String, String>? versionNameSuffix;
  Map<String, String>? versionCode;
  Map<String, String>? minSdkVersion;
  Map<String, String>? signingConfig;
  Map<String, Map<String, String>>? firebaseConfig;
  List<CustomResValueModel>? resValues;
  List<CustomResValueModel>? buildConfigFields;
  final List<String> environmentOptions;
  FlavorModel({
    this.name,
    this.packageId,
    this.imagePaths,
    this.versionNameSuffix,
    this.versionCode,
    this.minSdkVersion,
    this.signingConfig,
    this.firebaseConfig,
    this.resValues,
    this.buildConfigFields,
    required this.environmentOptions,
  });
}

class CustomResValueModel {
  final String title;
  final String flavor;
  final Map<String, String> values;
  CustomResValueModel({
    required this.title,
    required this.flavor,
    required this.values,
  });

  Map<String, dynamic> toMap() {
    return {'${title}': values};
  }

  @override
  String toString() => 'CustomResValueModel(title: $title, values: $values)';
}
