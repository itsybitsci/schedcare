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
  final DateTime modifiedAt;
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
      required this.modifiedAt,
      required this.createdAt});

  factory Patient.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Patient(
      uid: snapshot.id,
      email: data[ModelFields.email],
      role: data[ModelFields.role],
      firstName: data[ModelFields.firstName],
      middleName: data[ModelFields.middleName] ?? '',
      lastName: data[ModelFields.lastName],
      suffix: data[ModelFields.suffix] ?? '',
      age: data[ModelFields.age],
      birthDate: data[ModelFields.birthDate].toDate(),
      sex: data[ModelFields.sex],
      phoneNumber: data[ModelFields.phoneNumber],
      address: data[ModelFields.address],
      civilStatus: data[ModelFields.civilStatus],
      classification: data[ModelFields.classification] ?? '',
      uhsIdNumber: data[ModelFields.uhsIdNumber] ?? '',
      vaccinationStatus: data[ModelFields.vaccinationStatus],
      isApproved: data[ModelFields.isApproved],
      lastLogin: data[ModelFields.lastLogin].toDate(),
      modifiedAt: data[ModelFields.modifiedAt].toDate(),
      createdAt: data[ModelFields.createdAt].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.patientId: uid,
      ModelFields.email: email,
      ModelFields.role: role,
      ModelFields.firstName: firstName,
      ModelFields.middleName: middleName,
      ModelFields.lastName: lastName,
      ModelFields.suffix: suffix,
      ModelFields.age: age,
      ModelFields.birthDate: birthDate,
      ModelFields.sex: sex,
      ModelFields.phoneNumber: phoneNumber,
      ModelFields.address: address,
      ModelFields.civilStatus: civilStatus,
      ModelFields.classification: classification,
      ModelFields.uhsIdNumber: uhsIdNumber,
      ModelFields.vaccinationStatus: vaccinationStatus,
      ModelFields.isApproved: isApproved,
      ModelFields.lastLogin: lastLogin,
      ModelFields.modifiedAt: modifiedAt,
      ModelFields.createdAt: createdAt,
    };
  }
}

class Doctor {
  final String uid;
  final String email;
  final String role;
  final String prefix;
  final String firstName;
  final String middleName;
  final String lastName;
  final String suffix;
  final String sex;
  final String specialization;
  final bool isApproved;
  final DateTime lastLogin;
  final DateTime modifiedAt;
  final DateTime createdAt;

  Doctor(
      {required this.uid,
      required this.email,
      required this.role,
      required this.prefix,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.suffix,
      required this.sex,
      required this.specialization,
      required this.isApproved,
      required this.lastLogin,
      required this.modifiedAt,
      required this.createdAt});

  factory Doctor.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Doctor(
      uid: snapshot.id,
      email: data[ModelFields.email],
      role: data[ModelFields.role],
      prefix: data[ModelFields.prefix] ?? '',
      firstName: data[ModelFields.firstName],
      middleName: data[ModelFields.middleName] ?? '',
      lastName: data[ModelFields.lastName],
      suffix: data[ModelFields.suffix] ?? '',
      sex: data[ModelFields.sex],
      specialization: data[ModelFields.specialization],
      isApproved: data[ModelFields.isApproved],
      lastLogin: data[ModelFields.lastLogin].toDate(),
      modifiedAt: data[ModelFields.modifiedAt].toDate(),
      createdAt: data[ModelFields.createdAt].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.doctorId: uid,
      ModelFields.email: email,
      ModelFields.role: role,
      ModelFields.prefix: prefix,
      ModelFields.firstName: firstName,
      ModelFields.middleName: middleName,
      ModelFields.lastName: lastName,
      ModelFields.suffix: suffix,
      ModelFields.sex: sex,
      ModelFields.specialization: specialization,
      ModelFields.isApproved: isApproved,
      ModelFields.lastLogin: lastLogin,
      ModelFields.modifiedAt: modifiedAt,
      ModelFields.createdAt: createdAt,
    };
  }
}
