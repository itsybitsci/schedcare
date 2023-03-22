import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedcare/utilities/constants.dart';

class Patient {
  final String uid;
  final String email;
  final String role;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final int age;
  final DateTime birthDate;
  final String sex;
  final String phoneNumber;
  final String address;
  final String civilStatus;
  final String classification;
  final String uhsIdNumber;
  final String vaccinationStatus;
  final bool isApproved;
  final DateTime lastLogin;
  final DateTime createdAt;

  Patient(
      {required this.uid,
      required this.email,
      required this.role,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.suffix,
      required this.age,
      required this.birthDate,
      required this.sex,
      required this.phoneNumber,
      required this.address,
      required this.civilStatus,
      required this.classification,
      required this.uhsIdNumber,
      required this.vaccinationStatus,
      required this.isApproved,
      required this.lastLogin,
      required this.createdAt});

  factory Patient.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return Patient(
      uid: snapshot.id,
      email: userData[ModelFields.email],
      role: userData[ModelFields.role],
      firstName: userData[ModelFields.firstName],
      middleName: userData[ModelFields.middleName] ?? '',
      lastName: userData[ModelFields.lastName],
      suffix: userData[ModelFields.suffix] ?? '',
      age: userData[ModelFields.age],
      birthDate: userData[ModelFields.birthDate].toDate(),
      sex: userData[ModelFields.sex],
      phoneNumber: userData[ModelFields.phoneNumber],
      address: userData[ModelFields.address],
      civilStatus: userData[ModelFields.civilStatus],
      classification: userData[ModelFields.classification] ?? '',
      uhsIdNumber: userData[ModelFields.uhsIdNumber] ?? '',
      vaccinationStatus: userData[ModelFields.vaccinationStatus],
      isApproved: userData[ModelFields.isApproved],
      lastLogin: userData[ModelFields.lastLogin].toDate(),
      createdAt: userData[ModelFields.createdAt].toDate(),
    );
  }
}

class Doctor {
  final String uid;
  final String email;
  final String role;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String sex;
  final String specialization;
  final bool isApproved;
  final DateTime lastLogin;
  final DateTime createdAt;

  Doctor(
      {required this.uid,
      required this.email,
      required this.role,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.suffix,
      required this.sex,
      required this.specialization,
      required this.isApproved,
      required this.lastLogin,
      required this.createdAt});

  factory Doctor.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return Doctor(
      uid: snapshot.id,
      email: userData[ModelFields.email],
      role: userData[ModelFields.role],
      firstName: userData[ModelFields.firstName],
      middleName: userData[ModelFields.middleName] ?? '',
      lastName: userData[ModelFields.lastName],
      suffix: userData[ModelFields.suffix] ?? '',
      sex: userData[ModelFields.sex],
      specialization: userData[ModelFields.specialization],
      isApproved: userData[ModelFields.isApproved],
      lastLogin: userData[ModelFields.lastLogin].toDate(),
      createdAt: userData[ModelFields.createdAt].toDate(),
    );
  }
}
