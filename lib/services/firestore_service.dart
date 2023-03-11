import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schedcare/utilities/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firebaseDb = FirebaseFirestore.instance;

  Future<void> registerUser(
    Map<String, dynamic> userData,
    String userUid,
  ) async {
    try {
      await _firebaseDb
          .collection(FirestoreConstants.usersCollection)
          .doc(userUid)
          .set(userData);
    } catch (e) {
      throw Exception(e).toString();
    }
  }

  Future<void> logUser(User user) async {
    try {
      await _firebaseDb
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .update({
        'lastLogin': user.metadata.lastSignInTime,
      });
    } catch (e) {
      throw Exception(e).toString();
    }
  }

  Future<bool> addUserToFirestoreDatabase(
      Map<String, dynamic> userData, User user) async {
    bool isSuccess = false;

    await registerUser(userData, user.uid).then((_) {
      isSuccess = true;
    }).catchError((_) {
      isSuccess = false;
    });
    return isSuccess;
  }

  Future<DocumentSnapshot?> getFirestoreData(User user) async {
    DocumentSnapshot snapshot = await _firebaseDb
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .get();
    return snapshot;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserSnapshots(User user) {
    return _firebaseDb
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .snapshots();
  }
}
