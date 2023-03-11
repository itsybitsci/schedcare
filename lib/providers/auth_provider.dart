import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schedcare/services/firestore_service.dart';
import 'package:schedcare/services/auth_service.dart';
import 'package:schedcare/models/user_models.dart';
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

  bool get isLoading => _isLoading;
  User? get isLoggedIn => authService.currentUser;
  UserCredential? get userCredential => _userCredential;
  User? get user => authService.currentUser;
  Patient? get patient => _patient;
  Doctor? get doctor => _doctor;
  String? get role => _role;

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

      _role = Helper.getRoleFromSnapshot(snapshot!);

      if (_role!.toLowerCase() == RegistrationConstants.patient.toLowerCase()) {
        _patient = Patient.fromDocumentSnapshot(snapshot);
      } else {
        _doctor = Doctor.fromDocumentSnapshot(snapshot);
      }

      await fireStoreService.logUser(user);

      setLoading(false);
      notifyListeners();
      return _userCredential;
    } catch (e) {
      setLoading(false);
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

      userData.addAll({
        'lastLogin': user.metadata.lastSignInTime,
        'createdAt': user.metadata.creationTime,
      });

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

  Future<void> getFirestoreData(User user, String collectionName) async {
    setLoading(true);
    try {
      DocumentSnapshot? snapshot =
          await fireStoreService.getFirestoreData(user);

      if (_role!.toLowerCase() == RegistrationConstants.patient.toLowerCase()) {
        _patient = Patient.fromDocumentSnapshot(snapshot!);
      } else {
        _doctor = Doctor.fromDocumentSnapshot(snapshot!);
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

final firebaseProvider =
    ChangeNotifierProvider<FirebaseProvider>((ref) => FirebaseProvider());
