import 'package:flutter/material.dart';
import 'package:launcher/models/user_model.dart';

class HomePage extends StatelessWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome Home! ${user.email}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32.0)),
      ),
    );
  }
}
