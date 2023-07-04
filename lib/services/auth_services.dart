import 'package:chat_app_firebase/helper/helper_function.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'database_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //login
  Future loginWithEmailandPassword(String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // call our database service to update user data
        return true;
      }
    }
    // for catching firebase exception, this is how it is used
    on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //register
  Future registerUserWithEmailandPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        // call our database service to update user data
        await DatabaseService(uid: user.uid).savingUserData(fullName, email);
        return true;
      }
    }
    // for catching firebase exception, this is how it is used
    on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //signout
  Future signOut() async {
    try {
      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmailSF("");
      await HelperFunction.saveUserNameSF("");

      // only this firebase signout is enough, but
      // setting shared preferences status is also require
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
