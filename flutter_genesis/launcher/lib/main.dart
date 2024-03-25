// START REMOVE BLOCK: noAuth
import 'package:firebase_core/firebase_core.dart';
// END REMOVE BLOCK: noAuth
import 'package:flutter/material.dart';
// START REMOVE BLOCK: noAuth
import 'package:launcher/firebase_options.dart';
// END REMOVE BLOCK: noAuth
import 'package:launcher/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
// START REMOVE BLOCK: noAuth
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
// END REMOVE BLOCK: noAuth
  runApp(const MyApp());
}
