import 'package:firebase_auth/firebase_auth.dart';
import 'package:schedcare/utilities/helpers.dart';

class FirebaseAuthenticationService {
  final firebaseAuthenticationInstance = FirebaseAuth.instance;

  User? get currentUser => firebaseAuthenticationInstance.currentUser;

  Future<UserCredential?> logInWithEmailAndPassword(
      String email, String password) async {
    return await firebaseAuthenticationInstance.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    return await firebaseAuthenticationInstance.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await firebaseAuthenticationInstance.signOut();
  }

  Future<void> sendEmailVerification(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseException catch (e) {
      showToast(e.code);
      throw Exception(e.code);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuthenticationInstance.sendPasswordResetEmail(email: email);
  }

  Future<void> updatePassword(String newPassword) async {
    await firebaseAuthenticationInstance.currentUser!
        .updatePassword(newPassword);
  }
}
