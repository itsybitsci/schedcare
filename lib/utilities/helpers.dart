import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

String getRoleFromSnapshot(DocumentSnapshot snapshot) {
  Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
  return userData['role'];
}

Future<void> showToast(String message) async {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
  );
}
