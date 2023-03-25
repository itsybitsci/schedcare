import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firebaseDb = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String collection, String id) async {
    return await _firebaseDb.collection(collection).doc(id).get();
  }

  Future<void> updateDocument(
      Map<String, dynamic> data, String collection, String id) async {
    return await _firebaseDb.collection(collection).doc(id).update(data);
  }

  Future<void> setDocument(
      Map<String, dynamic> data, String collection, String id) async {
    return await _firebaseDb.collection(collection).doc(id).set(data);
  }

  Future<void> deleteDocument(String collection, String docId) async {
    return await _firebaseDb.collection(collection).doc(docId).delete();
  }
}
