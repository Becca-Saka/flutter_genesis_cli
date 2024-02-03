import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:launcher/exceptions/auth_exception.dart';
import 'package:launcher/services/auth_services.dart';
import 'package:launcher/ui/widgets/app_form_field.dart';
import 'package:launcher/utils/snackbar/app_snackbar.dart';
import 'package:launcher/utils/validators.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseService firebaseService = FirebaseService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16.0),
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Sign up to continue',
                ),
                const SizedBox(height: 80.0),
                AppTextField(
                  labelText: 'Email',
                  controller: emailController,
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 16.0),
                AppTextField(
                  labelText: 'Password',
                  controller: passwordController,
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  height: 48.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final isValidated =
                            formKey.currentState?.validate() ?? false;
                        if (isValidated) {
                          final response = await firebaseService.createAccount(
                            emailController.text,
                            passwordController.text,
                          );
                          if (!context.mounted) return;
                          if (response) {
                            showSnackbar(context,
                                'Account created, Please verify your email');

                            Navigator.of(context).pop();
                          }
                        }
                      } on AuthException catch (e) {
                        showSnackbar(context, e.message);
                      }
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(context).pop(),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
