class ExcludableCodes {
  final String appPath;
  ExcludableCodes(this.appPath);

  List<String> get exclude => excludeImports() + excludeCodes();

  List<String> excludeImports() => [
        "import 'package:firebase_core/firebase_core.dart';",
        "import 'package:${appPath}/firebase_options.dart';",
        "import 'package:${appPath}/ui/sign_in_page.dart';",
        "import 'package:${appPath}/ui/sign_up_page.dart';",
      ];
  List<String> excludeCodes() => [
        "static const String signIn = '/sign_in';",
        "static const String signUp = '/sign_up';",
        '''  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );''',
        ''' case AppRoutes.signIn:
        return MaterialPageRoute(
          builder: (context) => const SignInPage(),
        );''',
        ''' case AppRoutes.signUp:
        return MaterialPageRoute(
          builder: (context) => const SignUpPage(),
        );''',
      ];
  Map<String, String> excludeCodesWithReplacement() {
    return {
      'initialRoute = AppRoutes.signIn': 'initialRoute = AppRoutes.home',
    };
  }
}
