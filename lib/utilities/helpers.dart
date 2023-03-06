import 'package:cloud_firestore/cloud_firestore.dart';

class Helper {
  static String getRoleFromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return userData['role'];
  }
}
