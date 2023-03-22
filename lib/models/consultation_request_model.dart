import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedcare/utilities/constants.dart';

class ConsultationRequest {
  final String patientUid;
  final String doctorUid;
  final String body;
  final String status;
  final String consultationType;
  final DateTime consultationDate;
  final DateTime createdAt;
  String? meetingId;

  ConsultationRequest(
      {required this.patientUid,
      required this.doctorUid,
      required this.body,
      required this.consultationType,
      required this.consultationDate,
      required this.status,
      required this.createdAt,
      this.meetingId});

  factory ConsultationRequest.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return ConsultationRequest(
      patientUid: userData[ModelFields.patientUid],
      doctorUid: userData[ModelFields.doctorUid],
      body: userData[ModelFields.requestBody],
      status: userData[ModelFields.status],
      consultationType: userData[ModelFields.consultationType],
      consultationDate: userData[ModelFields.consultationDate].toDate(),
      createdAt: userData[ModelFields.createdAt].toDate(),
      meetingId: userData[ModelFields.meetingId] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.patientUid: patientUid,
      ModelFields.doctorUid: doctorUid,
      ModelFields.requestBody: body,
      ModelFields.status: status,
      ModelFields.consultationType: consultationType,
      ModelFields.consultationDate: consultationDate,
      ModelFields.createdAt: createdAt,
      ModelFields.meetingId: meetingId ?? ''
    };
  }
}
