import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedcare/utilities/constants.dart';

class ConsultationRequest {
  final String patientUid;
  final String doctorUid;
  final String requestBody;
  final String status;
  final String consultationType;
  final DateTime consultationDate;
  final DateTime createdAt;
  final String meetingId;

  ConsultationRequest(
    this.meetingId, {
    required this.patientUid,
    required this.doctorUid,
    required this.requestBody,
    required this.consultationType,
    required this.consultationDate,
    required this.status,
    required this.createdAt,
  });

  factory ConsultationRequest.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return ConsultationRequest(
      userData[ModelFields.meetingId] ?? '',
      patientUid: userData[ModelFields.patientUid],
      doctorUid: userData[ModelFields.doctorUid],
      requestBody: userData[ModelFields.requestBody],
      status: userData[ModelFields.status],
      consultationType: userData[ModelFields.consultationType],
      consultationDate: userData[ModelFields.consultationDate].toDate(),
      createdAt: userData[ModelFields.createdAt].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.patientUid: patientUid,
      ModelFields.doctorUid: doctorUid,
      ModelFields.requestBody: requestBody,
      ModelFields.status: status,
      ModelFields.consultationType: consultationType,
      ModelFields.consultationDate: consultationDate,
      ModelFields.createdAt: createdAt,
      ModelFields.meetingId: meetingId
    };
  }
}
