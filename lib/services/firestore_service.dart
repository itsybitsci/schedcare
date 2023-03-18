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
        ModelFields.lastLogin: user.metadata.lastSignInTime,
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

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    try {
      return await _firebaseDb
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .get();
    } catch (e) {
      throw Exception(e).toString();
    }
  }

  Future<QuerySnapshot?> getUsersData() async {
    try {
      return await _firebaseDb
          .collection(FirestoreConstants.usersCollection)
          .get();
    } catch (e) {
      throw Exception(e).toString();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersSnapshots() {
    try {
      return _firebaseDb
          .collection(FirestoreConstants.usersCollection)
          .snapshots();
    } catch (e) {
      throw Exception(e).toString();
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserSnapshots(User user) {
    try {
      return _firebaseDb
          .collection(FirestoreConstants.usersCollection)
          .doc(user.uid)
          .snapshots();
    } catch (e) {
      throw Exception(e).toString();
    }
  }

  Future<bool> updateUser(Map<String, dynamic> userData, String uid) async {
    try {
      await _firebaseDb
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .update(userData);
      return true;
    } catch (e) {
      throw Exception(e).toString();
    }
  }
}
