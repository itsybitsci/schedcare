import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedcare/models/user_models.dart';
import 'package:schedcare/utilities/constants.dart';

class ConsultationRequest {
  final String docId;
  final String patientUid;
  final String doctorUid;
  final String consultationRequestBody;
  final String status;
  final String consultationType;
  final DateTime consultationDateTime;
  final DateTime createdAt;
  String? meetingId;

  ConsultationRequest(
      {required this.docId,
      required this.patientUid,
      required this.doctorUid,
      required this.consultationRequestBody,
      required this.consultationType,
      required this.consultationDateTime,
      required this.status,
      required this.createdAt,
      this.meetingId});

  factory ConsultationRequest.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    return ConsultationRequest(
      docId: userData[ModelFields.docId],
      patientUid: userData[ModelFields.patientUid],
      doctorUid: userData[ModelFields.doctorUid],
      consultationRequestBody: userData[ModelFields.consultationRequestBody],
      status: userData[ModelFields.status],
      consultationType: userData[ModelFields.consultationType],
      consultationDateTime: userData[ModelFields.consultationDateTime].toDate(),
      createdAt: userData[ModelFields.createdAt].toDate(),
      meetingId: userData[ModelFields.meetingId] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ModelFields.docId: docId,
      ModelFields.patientUid: patientUid,
      ModelFields.doctorUid: doctorUid,
      ModelFields.consultationRequestBody: consultationRequestBody,
      ModelFields.status: status,
      ModelFields.consultationType: consultationType,
      ModelFields.consultationDateTime: consultationDateTime,
      ModelFields.createdAt: createdAt,
      ModelFields.meetingId: meetingId ?? ''
    };
  }
}

class ViewConsultationRequestObject {
  final Doctor doctor;
  final ConsultationRequest consultationRequest;

  ViewConsultationRequestObject(
      {required this.doctor, required this.consultationRequest});
}
