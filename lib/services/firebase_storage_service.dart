import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _firebaseStorageInstance = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String consultationRequestId,
      String role, String fileName) async {
    final Reference ref = _firebaseStorageInstance
        .ref()
        .child(consultationRequestId)
        .child('$role/$fileName');

    UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    final Reference ref = _firebaseStorageInstance.refFromURL(url);
    return await ref.delete();
  }
}
