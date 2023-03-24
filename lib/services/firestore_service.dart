import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';

class FirestoreService {
  final FirebaseFirestore _firebaseDb = FirebaseFirestore.instance;

  Future<void> registerUser(
    Map<String, dynamic> userData,
    String userUid,
  ) async {
    await _firebaseDb
        .collection(FirestoreConstants.usersCollection)
        .doc(userUid)
        .set(userData);
  }

  Future<void> logUser(User user) async {
    await _firebaseDb
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .update(
      {
        ModelFields.lastLogin: user.metadata.lastSignInTime,
      },
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    try {
      return await _firebaseDb
          .collection(FirestoreConstants.usersCollection)
          .doc(uid)
          .get();
    } on FirebaseException catch (e) {
      showToast(e.code);
      throw Exception(e.code);
    }
  }

  Future<void> updateUser(Map<String, dynamic> userData, String uid) async {
    return await _firebaseDb
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .update(userData);
  }

  Future<void> sendConsultationRequest(
      ConsultationRequest consultationRequest) async {
    return await _firebaseDb
        .collection(FirestoreConstants.consultationRequestsCollection)
        .doc(consultationRequest.docId)
        .set(
          consultationRequest.toMap(),
        );
  }

  Future<void> deleteDocument(String collection, String docId) async {
    return await _firebaseDb.collection(collection).doc(docId).delete();
  }
}
