import 'package:flutter_genesis_cli/src/commands/process/http_procress.dart';
import 'package:flutter_genesis_cli/src/commands/process/process.dart';
import 'package:flutter_genesis_cli/src/shared/extensions/lists.dart';
import 'package:flutter_genesis_cli/src/shared/logger.dart';
import 'package:flutter_genesis_cli/src/shared/models/firebase_app_details.dart';
import 'package:flutter_genesis_cli/src/shared/models/flutter_app_details.dart';

Future<FirebaseAppDetails> loadFirebaseOptions(
    FirebaseAppDetails firebaseAppDetails,
    List<FirebaseOptions> selectedOptions) async {
  if (selectedOptions.contains(FirebaseOptions.authentication)) {
    final options = await _getAuthenticationOptions();
    firebaseAppDetails = firebaseAppDetails.copyWith(
      authenticationMethods: options,
    );
  }
  return firebaseAppDetails;
}

Future<List<AuthenticationMethod>> _getAuthenticationOptions() async {
  const options = AuthenticationMethod.values;
  final answerIndexes = process.getMultiSelectInput(
    prompt: 'Please select authentication options',
    options: options.names,
    defaultValue: [AuthenticationMethod.email.name],
  );
  if (answerIndexes.isEmpty) {
    e('Please select an authentication option');
    _getAuthenticationOptions();
  }
  final answers = options
      .where((element) => answerIndexes.contains(options.indexOf(element)))
      .toList();
  m('You selected: ${answers.names.joined}');
  return answers;
}

Future<void> _enableEmailPassWordSignIn(
    FlutterAppDetails flutterAppDetails) async {
  if (flutterAppDetails.firebaseAppDetails?.cliToken == null ||
      flutterAppDetails.firebaseAppDetails?.projectId == null) {
    return;
  }
  HttpProcess http = HttpProcess();
  final url =
      "https://identitytoolkit.clients6.google.com/v2/projects/${flutterAppDetails.firebaseAppDetails?.projectId}/config?updateMask=signIn.email.enabled,signIn.email.passwordRequired&alt=json&key=${flutterAppDetails.firebaseAppDetails!.cliToken}";
  http.patchData(url);
}
