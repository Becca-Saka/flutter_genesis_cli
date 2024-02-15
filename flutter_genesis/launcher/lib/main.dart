import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:launcher/firebase_options.dart';
import 'package:launcher/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
