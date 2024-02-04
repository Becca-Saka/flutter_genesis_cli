import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: error ? Colors.red : null,
      content: Text(message,
          style: TextStyle(
            color: error ? Colors.red : null,
          )),
    ),
  );
}
