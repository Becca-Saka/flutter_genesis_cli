import 'package:cli_app/data/database.dart';
import 'package:cli_app/models/firebase_app_details.dart';
import 'package:cli_app/process/process.dart';
import 'package:cli_app/shared/validators.dart';
import 'package:cli_app/templates/firebase_template/flutter_fire_cli.dart';

enum FirebaseOptions {
  authentication,
  database,
  firestore,
  storage,
  messaging,
  functions,
  hosting,
  analytics,
  performance,
  remoteConfig,
}

class FirebaseTemplates {
  final AdireCliProcess process = AdireCliProcess();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  List<FirebaseOptions> selectedOptions = [];

  Future<FirebaseAppDetails> init() async {
    getOptions();
    String firebaseToken = await getFirebaseCliToken();
    await FlutterFireCli.instance.getAppId(firebaseToken);
    if (selectedOptions.contains(FirebaseOptions.authentication)) {}

    return FirebaseAppDetails(
      firebaseProjectId: null,
      cliToken: firebaseToken,
      selectedOptions: selectedOptions,
    );
  }

  Future<String> getFirebaseCliToken() async {
    String firebaseToken;
    final results = await databaseHelper.query(
      where: '',
      whereArgs: [],
      columns: [],
    );
    if (results.isNotEmpty) {
      final token = results.first['value'] as String;
      firebaseToken = token;
    } else {
      firebaseToken = process.getInput(
        prompt: 'Enter your Firebase CLI token',
        validator: (val) => AppValidators.notNullAndNotEmpty(val,
            message: 'Token cannot be empty'),
      );
      await databaseHelper.insertUpdate({
        'id': 'firebase_ci',
        'value': firebaseToken,
      });
    }
    return firebaseToken;
  }

  void getOptions() {
    final options = FirebaseOptions.values;
    final selectedOptionIndex = process.getMultiSelectInput(
      prompt: 'What firebase options would you like?',
      options: options.map((e) => e.name).toList(),
    );
    selectedOptions = selectedOptionIndex.map((e) => options[e]).toList();
  }
}
