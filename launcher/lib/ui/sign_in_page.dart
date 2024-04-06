import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:launcher/app/app_routes.dart';
import 'package:launcher/exceptions/auth_exception.dart';
import 'package:launcher/services/auth_services.dart';
import 'package:launcher/ui/widgets/app_form_field.dart';
import 'package:launcher/ui/widgets/app_icons.dart';
import 'package:launcher/utils/snackbar/app_snackbar.dart';
import 'package:launcher/utils/validators.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService firebaseService = AuthService();
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
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Sign in to continue',
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
                          final user = await firebaseService.login(
                            emailController.text,
                            passwordController.text,
                          );
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.home,
                            (route) => route.isFirst,
                            arguments: user,
                          );
                        }
                      } on AuthException catch (e) {
                        showSnackbar(context, e.message);
                      }
                    },
                    child: const Text(
                      'Sign In',
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
                      text: 'Don\'t have an account? ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.of(context)
                                .pushNamed(AppRoutes.signUp),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
// START REMOVE BLOCK: googleAuth
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcons(
                      onPressed: () async {
                        try {
                          final user =
                              await firebaseService.logInWithGoogleUser();
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.home,
                            (route) => route.isFirst,
                            arguments: user,
                          );
                        } on AuthException catch (e) {
                          showSnackbar(context, e.message);
                        }
                      },
                      icon: AppIconData.googleSignIn,
                    ),
                  ],
                ),
// END REMOVE BLOCK: googleAuth
              ],
            ),
          ),
        ),
      ),
    );
  }
}
