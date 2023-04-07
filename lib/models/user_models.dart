import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedcare/utilities/constants.dart';

class Patient {
  final String id;
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
      {required this.id,
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
    return Patient(
      id: snapshot.get(ModelFields.id),
      email: snapshot.get(ModelFields.email),
      role: snapshot.get(ModelFields.role),
      firstName: snapshot.get(ModelFields.firstName),
      middleName: snapshot.get(ModelFields.middleName) ?? '',
      lastName: snapshot.get(ModelFields.lastName),
      suffix: snapshot.get(ModelFields.suffix) ?? '',
      age: snapshot.get(ModelFields.age),
      birthDate: snapshot.get(ModelFields.birthDate).toDate(),
      sex: snapshot.get(ModelFields.sex),
      phoneNumber: snapshot.get(ModelFields.phoneNumber),
      address: snapshot.get(ModelFields.address),
      civilStatus: snapshot.get(ModelFields.civilStatus),
      classification: snapshot.get(ModelFields.classification) ?? '',
      uhsIdNumber: snapshot.get(ModelFields.uhsIdNumber) ?? '',
      vaccinationStatus: snapshot.get(ModelFields.vaccinationStatus),
      isApproved: snapshot.get(ModelFields.isApproved),
      lastLogin: snapshot.get(ModelFields.lastLogin).toDate(),
      modifiedAt: snapshot.get(ModelFields.modifiedAt).toDate(),
      createdAt: snapshot.get(ModelFields.createdAt).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.patientId: id,
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
  final String id;
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
      {required this.id,
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
    return Doctor(
      id: snapshot.get(ModelFields.id),
      email: snapshot.get(ModelFields.email),
      role: snapshot.get(ModelFields.role),
      prefix: snapshot.get(ModelFields.prefix) ?? '',
      firstName: snapshot.get(ModelFields.firstName),
      middleName: snapshot.get(ModelFields.middleName) ?? '',
      lastName: snapshot.get(ModelFields.lastName),
      suffix: snapshot.get(ModelFields.suffix) ?? '',
      sex: snapshot.get(ModelFields.sex),
      specialization: snapshot.get(ModelFields.specialization),
      isApproved: snapshot.get(ModelFields.isApproved),
      lastLogin: snapshot.get(ModelFields.lastLogin).toDate(),
      modifiedAt: snapshot.get(ModelFields.modifiedAt).toDate(),
      createdAt: snapshot.get(ModelFields.createdAt).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.doctorId: id,
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
