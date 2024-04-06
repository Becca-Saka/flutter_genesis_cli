import 'package:flutter/material.dart';
import 'package:launcher/ui/home_page.dart';
// START REMOVE BLOCK: noAuth
import 'package:launcher/ui/sign_in_page.dart';
import 'package:launcher/ui/sign_up_page.dart';

// END REMOVE BLOCK: noAuth
class AppRoutes {
// START REMOVE BLOCK: noAuth
  static const String signIn = '/sign_in';
  static const String signUp = '/sign_up';
// END REMOVE BLOCK: noAuth
  static const String home = '/home';
}

class AppRouter {
// START REMOVE BLOCK: noAuth
  static const String initialRoute = AppRoutes.signIn;
// END REMOVE BLOCK: noAuth
// START REMOVE COMMENT: noAuth

  // static const String initialRoute = AppRoutes.home;

// END REMOVE COMMENT: noAuth
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
// START REMOVE BLOCK: noAuth
      case AppRoutes.signIn:
        return MaterialPageRoute(
          builder: (context) => const SignInPage(),
        );
      case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (context) => const SignUpPage(),
        );
// END REMOVE BLOCK: noAuth
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
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
