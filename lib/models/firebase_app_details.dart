import 'package:cli_app/templates/firebase_template/firebase_templates.dart';

class FirebaseAppDetails {
  final String? firebaseProjectId;
  final String? cliToken;
  List<FirebaseOptions> selectedOptions;

  FirebaseAppDetails({
    this.firebaseProjectId,
    this.cliToken,
    required this.selectedOptions,
  });
}
