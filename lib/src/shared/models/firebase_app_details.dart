// ignore_for_file: public_member_api_docs, sort_constructors_first
enum FirebaseOptions {
  core,
  authentication,
  database,
  firestore,
  storage,
  messaging,
  functions,
  analytics,
  performance,
  remoteConfig,
  inAppMessaging,
  dynamicLinks,
  crashlytics,
}

final firebasePackagesMap = {
  FirebaseOptions.core: 'firebase_core',
  FirebaseOptions.authentication: 'firebase_auth',
  FirebaseOptions.database: 'firebase_database',
  FirebaseOptions.firestore: 'cloud_firestore',
  FirebaseOptions.storage: 'firebase_storage',
  FirebaseOptions.messaging: 'firebase_messaging',
  FirebaseOptions.functions: 'cloud_functions',
  FirebaseOptions.analytics: 'firebase_analytics',
  FirebaseOptions.performance: 'firebase_performance',
  FirebaseOptions.remoteConfig: 'firebase_remote_config',
  FirebaseOptions.inAppMessaging: 'firebase_in_app_messaging',
  FirebaseOptions.dynamicLinks: 'firebase_dynamic_links',
  FirebaseOptions.crashlytics: 'firebase_crashlytics',
};

final authPackagesMap = {
  AuthenticationMethod.google: 'google_sign_in',
};

enum AuthenticationMethod {
  email,
  phone,
  anonymous,
  google,
  apple,
  facebook,
  //TODO: add more providers
  //github, twitter, microsoft, yahoo, game center,
}

class FirebaseAppDetails {
  final String? projectId;
  final String? projectName;
  final String cliToken;
  List<FirebaseFlavorConfig>? flavorConfigs;
  List<FirebaseOptions> selectedOptions;
  List<AuthenticationMethod>? authenticationMethods;

  FirebaseAppDetails({
    this.projectId,
    this.projectName,
    required this.cliToken,
    required this.selectedOptions,
    this.flavorConfigs,
    this.authenticationMethods,
  }) : assert(
            projectId != null && projectName != null || flavorConfigs != null);

  FirebaseAppDetails copyWith({
    String? projectId,
    String? projectName,
    String? cliToken,
    List<FirebaseOptions>? selectedOptions,
    List<AuthenticationMethod>? authenticationMethods,
    List<FirebaseFlavorConfig>? flavorConfigs,
  }) {
    return FirebaseAppDetails(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      cliToken: cliToken ?? this.cliToken,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      authenticationMethods:
          authenticationMethods ?? this.authenticationMethods,
      flavorConfigs: flavorConfigs ?? this.flavorConfigs,
    );
  }
}

class FirebaseFlavorConfig {
  final String flavor;
  final String projectId;
  final String projectName;
  final String packageName;
  FirebaseFlavorConfig({
    required this.flavor,
    required this.projectId,
    required this.projectName,
    required this.packageName,
  });
}
