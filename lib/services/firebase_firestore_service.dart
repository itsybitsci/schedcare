import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFirestoreService {
  final _firebaseFirestoreInstance = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String collection, String id) async {
    return await _firebaseFirestoreInstance
        .collection(collection)
        .doc(id)
        .get();
  }

  Future<void> updateDocument(
      Map<String, dynamic> data, String collection, String id) async {
    return await _firebaseFirestoreInstance
        .collection(collection)
        .doc(id)
        .update(data);
  }

  Future<void> setDocument(
      Map<String, dynamic> data, String collection, String id) async {
    return await _firebaseFirestoreInstance
        .collection(collection)
        .doc(id)
        .set(data);
  }

  Future<void> deleteDocument(String collection, String docId) async {
    return await _firebaseFirestoreInstance
        .collection(collection)
        .doc(docId)
        .delete();
  }
}
