import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/services/firebase_authentication_service.dart';
import 'package:schedcare/services/firebase_cloud_messaging_service.dart';
import 'package:schedcare/services/firebase_firestore_service.dart';
import 'package:schedcare/services/firebase_storage_service.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';

class FirebaseServicesProvider extends ChangeNotifier {
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();
  final FirebaseFirestoreService _firebaseFirestoreService =
      FirebaseFirestoreService();
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService();
  final FirebaseStorageService _firebaseStorageService =
      FirebaseStorageService();
  bool _isLoading = false;
  bool _isLoggingIn = false;
  String? _role;
  String? _deviceToken;

  bool get getLoading => _isLoading;

  bool get getLoggingIn => _isLoggingIn;

  User? get getLogin => _firebaseAuthenticationService.currentUser;

  User? get getCurrentUser => _firebaseAuthenticationService.currentUser;

  String? get getRole => _role;

  FirebaseAuthenticationService get getFirebaseAuthenticationService =>
      _firebaseAuthenticationService;

  FirebaseFirestoreService get getFirebaseFirestoreService =>
      _firebaseFirestoreService;

  FirebaseMessagingService get getFirebaseCloudMessagingService =>
      _firebaseMessagingService;

  FirebaseStorageService get getFirebaseStorageService =>
      _firebaseStorageService;

  setLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  setLoggingIn(bool loader) {
    _isLoggingIn = loader;
    notifyListeners();
  }

  Future<bool> logInWithEmailAndPassword(String email, String password) async {
    setLoading(true);
    setLoggingIn(true);
    try {
      UserCredential? userCredential = await _firebaseAuthenticationService
          .logInWithEmailAndPassword(email, password);
      User user = userCredential!.user!;

      DocumentSnapshot? snapshot = await _firebaseFirestoreService.getDocument(
          FirebaseConstants.usersCollection, user.uid);

      _role = snapshot.get(ModelFields.role).toString().toLowerCase() ==
              AppConstants.patient.toLowerCase()
          ? AppConstants.patient
          : AppConstants.doctor;

      await _firebaseFirestoreService.updateDocument({
        ModelFields.lastLogin: user.metadata.lastSignInTime,
      }, FirebaseConstants.usersCollection, user.uid);

      setLoading(false);
      setLoggingIn(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      setLoading(false);
      setLoggingIn(false);
      showToast(Exception(e).toString());
      throw Exception(e).toString();
    }
  }

  Future<bool> createUserWithEmailAndPassword(
      String email, String password, Map<String, dynamic> data) async {
    setLoading(true);
    try {
      UserCredential? userCredential = await _firebaseAuthenticationService
          .createUserWithEmailAndPassword(email, password);

      User user = userCredential!.user!;

      data.addAll(
        {
          ModelFields.id: user.uid,
          ModelFields.lastLogin: user.metadata.lastSignInTime,
          ModelFields.modifiedAt: user.metadata.creationTime,
          ModelFields.createdAt: user.metadata.creationTime,
        },
      );

      await _firebaseFirestoreService.setDocument(
          data, FirebaseConstants.usersCollection, user.uid);

      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    setLoading(true);
    setLoggingIn(true);
    try {
      await _firebaseFirestoreService.updateDocument({
        ModelFields.deviceTokens: FieldValue.arrayRemove([_deviceToken])
      }, FirebaseConstants.userTokensCollection, getCurrentUser!.uid).then(
          (_) async {
        await _firebaseAuthenticationService.signOut();
        showToast('Successfully logged out');
      });

      setLoading(false);
      setLoggingIn(false);
      notifyListeners();
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      setLoggingIn(false);
      throw Exception(e.code);
    }
  }

  Future<bool> updateUserProfile(
      Map<String, dynamic> data, String collection, String id) async {
    setLoading(true);
    try {
      await _firebaseFirestoreService.updateDocument(data, collection, id);
      showToast('Successfully updated profile');
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> updateConsultationRequest(
      Map<String, dynamic> data, String collection, String id) async {
    setLoading(true);
    try {
      await _firebaseFirestoreService.updateDocument(data, collection, id);
      showToast('Successfully updated consultation request');
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    setLoading(true);
    try {
      await _firebaseAuthenticationService.sendPasswordResetEmail(email);
      showToast('Kindly check your email');
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    setLoading(true);
    try {
      await _firebaseAuthenticationService.updatePassword(newPassword);
      showToast('Successfully updated password');
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> updateEmail(User user, String email) async {
    setLoading(true);
    try {
      await user.updateEmail(email);
      showToast('Successfully updated email');
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> sendConsultationRequest(
      Map<String, dynamic> data, String collection, String id) async {
    setLoading(true);
    try {
      await _firebaseFirestoreService.setDocument(data, collection, id);
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> deleteDocument(String collection, String documentId) async {
    setLoading(true);
    try {
      await _firebaseFirestoreService.deleteDocument(collection, documentId);
      showToast('Successfully deleted document');
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> getAndSaveDeviceToken() async {
    try {
      _deviceToken = await _firebaseMessagingService.getDeviceToken();
      if (_deviceToken != null) {
        DocumentSnapshot<Map<String, dynamic>> data =
            await _firebaseFirestoreService.getDocument(
                FirebaseConstants.userTokensCollection, getCurrentUser!.uid);

        if (data.exists) {
          await _firebaseFirestoreService.updateDocument({
            ModelFields.deviceTokens: FieldValue.arrayUnion([_deviceToken]),
            ModelFields.modifiedAt: DateTime.now(),
          }, FirebaseConstants.userTokensCollection,
              _firebaseAuthenticationService.currentUser!.uid);
        } else {
          await _firebaseFirestoreService.setDocument({
            ModelFields.deviceTokens: FieldValue.arrayUnion([_deviceToken]),
            ModelFields.modifiedAt: DateTime.now(),
            ModelFields.createdAt: DateTime.now(),
          }, FirebaseConstants.userTokensCollection,
              _firebaseAuthenticationService.currentUser!.uid);
        }
      }
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      throw Exception(e.code);
    }
  }

  Future<bool> rejectConsultationRequest(
      Map<String, dynamic> data, String collection, String id) async {
    setLoading(true);
    try {
      await _firebaseFirestoreService.updateDocument(data, collection, id);
      showToast('Successfully rejected consultation request');
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> approveConsultationRequest(
      Map<String, dynamic> data, String collection, String id) async {
    setLoading(true);
    try {
      await _firebaseFirestoreService.updateDocument(data, collection, id);
      showToast('Successfully approved consultation request');
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> setMeetingId(
      String consultationRequestId, String meetingId) async {
    setLoading(true);
    try {
      await _firebaseFirestoreService.updateDocument({
        ModelFields.meetingId: meetingId,
        ModelFields.modifiedAt: DateTime.now(),
      }, FirebaseConstants.consultationRequestsCollection,
          consultationRequestId);
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> uploadFile(File file, String consultationRequestId, String role,
      String fileName) async {
    setLoading(true);
    try {
      String url = await _firebaseStorageService.uploadFile(
          file, consultationRequestId, role, fileName);
      await _firebaseFirestoreService.updateDocument({
        role == AppConstants.patient
            ? ModelFields.patientAttachmentUrl
            : ModelFields.doctorAttachmentUrl: url,
        ModelFields.modifiedAt: DateTime.now(),
      }, FirebaseConstants.consultationRequestsCollection,
          consultationRequestId);
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> resetAttachmentUrl(
      String consultationRequestId, String role) async {
    setLoading(true);
    try {
      await _firebaseFirestoreService.updateDocument({
        role == AppConstants.patient
            ? ModelFields.patientAttachmentUrl
            : ModelFields.doctorAttachmentUrl: null,
        ModelFields.modifiedAt: DateTime.now(),
      }, FirebaseConstants.consultationRequestsCollection,
          consultationRequestId);
      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }
}

final firebaseServicesProvider =
    ChangeNotifierProvider<FirebaseServicesProvider>(
  (ref) => FirebaseServicesProvider(),
);
