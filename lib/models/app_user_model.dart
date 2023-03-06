import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String uid;
  final String email;
  final String role;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final int age;
  final String birthDate;
  final String sex;
  final String phoneNumber;
  final String address;
  final String civilStatus;
  final String classification;
  final String uhsIdNumber;
  final String vaccinationStatus;
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
      required this.lastLogin,
      required this.createdAt});

  factory Patient.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return Patient(
      uid: snapshot.id,
      email: userData['email'],
      role: userData['role'],
      firstName: userData['firstName'],
      middleName: userData['middleName'] ?? '',
      lastName: userData['lastName'],
      suffix: userData['suffix'] ?? '',
      age: userData['age'],
      birthDate: userData['birthDate'],
      sex: userData['sex'],
      phoneNumber: userData['phoneNumber'],
      address: userData['address'],
      civilStatus: userData['civilStatus'],
      classification: userData['classification'] ?? '',
      uhsIdNumber: userData['uhsIdNumber'] ?? '',
      vaccinationStatus: userData['vaccinationStatus'],
      lastLogin: userData['lastLogin'].toDate(),
      createdAt: userData['createdAt'].toDate(),
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
      required this.lastLogin,
      required this.createdAt});

  factory Doctor.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return Doctor(
      uid: snapshot.id,
      email: userData['email'],
      role: userData['role'],
      firstName: userData['firstName'],
      middleName: userData['middleName'] ?? '',
      lastName: userData['lastName'],
      suffix: userData['suffix'] ?? '',
      sex: userData['sex'],
      specialization: userData['specialization'],
      lastLogin: userData['lastLogin'].toDate(),
      createdAt: userData['createdAt'].toDate(),
    );
  }
}
