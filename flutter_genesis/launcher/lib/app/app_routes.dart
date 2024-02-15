import 'package:flutter/material.dart';
import 'package:launcher/models/user_model.dart';
import 'package:launcher/ui/home_page.dart';
import 'package:launcher/ui/sign_in_page.dart';
import 'package:launcher/ui/sign_up_page.dart';

class AppRoutes {
  static const String signIn = '/sign_in';
  static const String signUp = '/sign_up';
  static const String home = '/home';
}

class AppRouter {
  static const String initialRoute = AppRoutes.signIn;
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.signIn:
        return MaterialPageRoute(
          builder: (context) => const SignInPage(),
        );
      case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (context) => const SignUpPage(),
        );
      case AppRoutes.home:
        final user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (context) => HomePage(
            user: user,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const RouteNotFoundPage(),
        );
    }
  }
}

class RouteNotFoundPage extends StatelessWidget {
  const RouteNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Route not found'),
      ),
    );
  }
}
