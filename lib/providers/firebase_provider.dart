import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:schedcare/models/consultation_request_model.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/services/auth_service.dart';
import 'package:schedcare/services/firestore_service.dart';
import 'package:schedcare/utilities/constants.dart';
import 'package:schedcare/utilities/helpers.dart';

class FirebaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  UserCredential? _userCredential;
  Patient? _patient;
  Doctor? _doctor;
  String? _role;
  final AuthService _authService = AuthService();
  final FirestoreService _fireStoreService = FirestoreService();

  bool get getLoading => _isLoading;

  User? get getLogin => _authService.currentUser;

  UserCredential? get getUserCredential => _userCredential;

  User? get getCurrentUser => _authService.currentUser;

  Patient? get getPatient => _patient;

  Doctor? get getDoctor => _doctor;

  String? get getRole => _role;

  AuthService get getAuthService => _authService;

  FirestoreService get getFirestoreService => _fireStoreService;

  set setPatient(Patient patient) {
    _patient = patient;
  }

  set setDoctor(Doctor doctor) {
    _doctor = doctor;
    notifyListeners();
  }

  setLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  Stream<User?> get userStream {
    return _authService.userStream();
  }

  Future<bool> logInWithEmailAndPassword(String email, String password) async {
    setLoading(true);
    try {
      _userCredential =
          await _authService.logInWithEmailAndPassword(email, password);
      User? user = _userCredential!.user;

      DocumentSnapshot? snapshot =
          await _fireStoreService.getUserData(user!.uid);

      _role = snapshot.get(ModelFields.role).toString().toLowerCase() ==
              AppConstants.patient.toLowerCase()
          ? AppConstants.patient
          : AppConstants.doctor;

      if (_role!.toLowerCase() == AppConstants.patient.toLowerCase()) {
        _patient = Patient.fromSnapshot(snapshot);
      } else {
        _doctor = Doctor.fromSnapshot(snapshot);
      }

      await _fireStoreService.logUser(user);

      setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      setLoading(false);
      showToast(Exception(e).toString());
      throw Exception(e).toString();
    }
  }

  Future<bool> createUserWithEmailAndPassword(
      String email, String password, Map<String, dynamic> userData) async {
    setLoading(true);
    try {
      _userCredential =
          await _authService.createUserWithEmailAndPassword(email, password);

      User user = _userCredential!.user!;

      userData.addAll(
        {
          ModelFields.lastLogin: user.metadata.lastSignInTime,
          ModelFields.createdAt: user.metadata.creationTime,
        },
      );

      await _fireStoreService.registerUser(userData, user.uid);

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
    try {
      await _authService.signOut();
      showToast('Successfully logged out');
      setLoading(false);
      notifyListeners();
    } on FirebaseException catch (e) {
      showToast(e.code);
      setLoading(false);
      throw Exception(e.code);
    }
  }

  Future<bool> updateUser(Map<String, dynamic> userData, String uid) async {
    setLoading(true);
    try {
      await _fireStoreService.updateUser(userData, uid);
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

  Future<bool> sendPasswordResetEmail(String email) async {
    setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
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
      await _authService.updatePassword(newPassword);
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

  Future<bool> sendConsultationRequest(
      ConsultationRequest consultationRequest) async {
    setLoading(true);
    try {
      await _fireStoreService.sendConsultationRequest(consultationRequest);
      showToast('Successfully sent consultation request');
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

final firebaseProvider = ChangeNotifierProvider<FirebaseProvider>(
  (ref) => FirebaseProvider(),
);

final authStateChangeProvider = StreamProvider.autoDispose(
  (ref) {
    return FirebaseAuth.instance.authStateChanges();
  },
);

final userSnapShotProvider = FutureProvider.family
    .autoDispose<DocumentSnapshot<Map<String, dynamic>>, String>(
  (ref, uid) async {
    return await FirebaseFirestore.instance
        .collection(FirestoreConstants.usersCollection)
        .doc(uid)
        .get();
  },
);
