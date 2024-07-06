import 'package:flutter_genesis_cli/src/commands/process/process.dart';
import 'package:flutter_genesis_cli/src/shared/database.dart';
import 'package:flutter_genesis_cli/src/shared/validators.dart';

Future<String> getFirebaseCliToken() async {
  DatabaseHelper databaseHelper = DatabaseHelper();
//TODO:  firebase CLI token is deprecated use service accounts
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
      // initialText: tokenAdire,
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
