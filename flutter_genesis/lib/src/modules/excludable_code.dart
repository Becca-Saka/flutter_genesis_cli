// ///DUMP FOR BLOCKS AND LINES TO REMOVE - EDIT WITH CAUTION
// class ExcludableCodes {
//   final String appPath;
//   ExcludableCodes(this.appPath);

//   List<String> get nofirebasesLineExcluder => [
//         "import 'package:cloud_firestore/cloud_firestore.dart';",
//         "import 'package:${appPath}/models/user_model.dart';",
//         "final FirebaseFirestore _firestore = FirebaseFirestore.instance;"
//       ];
//   List<String> get nofirebaseBlockExcluder => [
//         "getCurrentUserData",
//         "saveUserDetails",
//       ];
//   List<String> get noGoogleLineExcluder => [
//         "import 'package:google_sign_in/google_sign_in.dart';",
//         "final _googleSignIn = GoogleSignIn(scopes: ['email']);",
//         "await _googleSignIn.signOut();",
//       ];
//   List<String> get noGoogleBlockExcluder => ["logInWithGoogleUser"];
// }
