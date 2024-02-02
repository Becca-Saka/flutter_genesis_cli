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

class FirebaseAppDetails {
  final String? projectId;
  final String? projectName;
  final String? cliToken;
  List<FirebaseOptions> selectedOptions;

  FirebaseAppDetails({
    this.projectId,
    this.projectName,
    this.cliToken,
    required this.selectedOptions,
  });
}
