import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:schedcare/utilities/constants.dart';

class FirebaseStorageService {
  final FirebaseStorage _firebaseStorageInstance = FirebaseStorage.instance;
  UploadTask? _uploadTask;

  UploadTask? get uploadTask => _uploadTask;

  Future<String> uploadFile(File file, String consultationRequestId,
      String role, String fileName) async {
    final Reference ref = _firebaseStorageInstance
        .ref()
        .child(FirebaseConstants.consultationRequestsCollection)
        .child(consultationRequestId)
        .child('$role/$fileName');

    _uploadTask = ref.putFile(file);
    final TaskSnapshot taskSnapshot =
        await _uploadTask!.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    final Reference ref = _firebaseStorageInstance.refFromURL(url);
    return await ref.delete();
  }
}
