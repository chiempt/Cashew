import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/accountAndBackup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

OAuthCredential? _credential;

Future<FirebaseFirestore?> firebaseGetDBInstanceAnonymous() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
    return FirebaseFirestore.instance;
  } catch (e) {
    print("There was an error with firebase login");
    print(e.toString());
    return null;
  }
}

// returns null if authentication unsuccessful
Future<FirebaseFirestore?> firebaseGetDBInstance() async {
  if (_credential != null) {
    try {
      await FirebaseAuth.instance.signInWithCredential(_credential!);
      updateSettings(
        "currentUserEmail",
        FirebaseAuth.instance.currentUser!.email,
        pagesNeedingRefresh: [],
        updateGlobalState: false,
      );
      return FirebaseFirestore.instance;
    } catch (e) {
      print("There was an error with firebase login");
      print(e.toString());
      print("will retry with a new credential");
      _credential = null;
      googleUser = null;
      return await firebaseGetDBInstance();
    }
  } else {
    try {
      if (googleUser == null) {
        await signInGoogle(silentSignIn: true);
      }
      // GoogleSignInAccount? googleUser = googleUser;

      final signIn.GoogleSignInAuthentication googleAuth =
          googleUser!.authentication;
      final signIn.GoogleSignInAuthorizationClient authClient =
          googleUser!.authorizationClient;
      final List<String> scopes = [
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/userinfo.email",
      ];
      final signIn.GoogleSignInClientAuthorization? auth =
          await authClient.authorizationForScopes(scopes);
      final String? accessToken = auth?.accessToken;

      _credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(_credential!);
      updateSettings(
          "currentUserEmail", FirebaseAuth.instance.currentUser!.email,
          updateGlobalState: true);
      return FirebaseFirestore.instance;
    } catch (e) {
      print("There was an error with firebase login and possibly google");
      print(e.toString());
      return null;
    }
  }
}
