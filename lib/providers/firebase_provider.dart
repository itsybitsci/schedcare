import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  AuthService authService = AuthService();
  FirestoreService fireStoreService = FirestoreService();

  bool get getLoading => _isLoading;
  User? get getLogin => authService.currentUser;
  UserCredential? get getUserCredential => _userCredential;
  User? get getCurrentUser => authService.currentUser;
  Patient? get getPatient => _patient;
  Doctor? get getDoctor => _doctor;
  String? get getRole => _role;

  set setPatient(Patient patient) {
    _patient = patient;
  }

  set setDoctor(Doctor doctor) {
    _doctor = doctor;
  }

  setLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  Stream<User?> get userStream {
    return authService.userStream();
  }

  Future<UserCredential?> logInWithEmailAndPassword(
      String email, String password) async {
    setLoading(true);
    try {
      _userCredential =
          await authService.logInWithEmailAndPassword(email, password);
      User? user = _userCredential!.user;

      DocumentSnapshot? snapshot =
          await fireStoreService.getFirestoreData(user!);

      _role = snapshot!.get(ModelFields.role).toString().toLowerCase() ==
              RegistrationConstants.patient.toLowerCase()
          ? RegistrationConstants.patient
          : RegistrationConstants.doctor;

      if (_role!.toLowerCase() == RegistrationConstants.patient.toLowerCase()) {
        _patient = Patient.fromSnapshot(snapshot);
      } else {
        _doctor = Doctor.fromSnapshot(snapshot);
      }

      await fireStoreService.logUser(user);

      setLoading(false);
      notifyListeners();
      return _userCredential;
    } catch (e) {
      setLoading(false);
      showToast(Exception(e).toString());
      throw Exception(e).toString();
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password, Map<String, dynamic> userData) async {
    setLoading(true);
    bool isSuccess = false;
    try {
      _userCredential =
          await authService.createUserWithEmailAndPassword(email, password);

      User user = _userCredential!.user!;

      userData.addAll(
        {
          ModelFields.lastLogin: user.metadata.lastSignInTime,
          ModelFields.createdAt: user.metadata.creationTime,
        },
      );

      isSuccess =
          await fireStoreService.addUserToFirestoreDatabase(userData, user);

      setLoading(false);
      notifyListeners();
      if (isSuccess) {
        return _userCredential;
      }
      throw Exception('Error in signing up user!');
    } catch (e) {
      setLoading(false);
      throw Exception(e).toString();
    }
  }

  Future<void> getFirestoreData(User user) async {
    setLoading(true);
    try {
      DocumentSnapshot? snapshot =
          await fireStoreService.getFirestoreData(user);

      if (_role!.toLowerCase() == RegistrationConstants.patient.toLowerCase()) {
        _patient = Patient.fromSnapshot(snapshot!);
      } else {
        _doctor = Doctor.fromSnapshot(snapshot!);
      }
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      throw Exception(e).toString();
    }
  }

  Future<void> signOut() async {
    setLoading(true);
    try {
      _patient = null;
      _doctor = null;
      _userCredential = null;
      await authService.signOut();
      setLoading(false);
      notifyListeners();
    } catch (e) {
      setLoading(false);
      throw Exception(e).toString();
    }
  }
}

final firebaseProvider = ChangeNotifierProvider<FirebaseProvider>(
  (ref) => FirebaseProvider(),
);

final authStateChangeProvider = StreamProvider.autoDispose(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final userSnapShotProvider = FutureProvider.family
    .autoDispose<DocumentSnapshot<Map<String, dynamic>>, String>(
  (ref, uid) => FirebaseFirestore.instance
      .collection(FirestoreConstants.usersCollection)
      .doc(uid)
      .get(),
);
